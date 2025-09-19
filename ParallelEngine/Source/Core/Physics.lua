--- @class Physics
local Physics = {}

Physics.PPM = 128 / 10
Physics.gravityX = 0
Physics.gravityY = 9.8

--- @type love.physics
local lovePhysics = love.physics

--- @type love.World|nil
local world = nil

function Physics.ResetWorld()
    if world then
        world:destroy()
        world = nil
    end
end

local function EnsureWorld()
    if not world then
        world = lovePhysics.newWorld(Physics.gravityX * Physics.PPM, Physics.gravityY * Physics.PPM, true)

        local function beginContact(a, b, contact)
            local ua = a:getUserData()
            local ub = b:getUserData()
            if ua and ub then
                if ua.OnCollisionEnter then
                    pcall(ua.OnCollisionEnter, ua, ub)
                end
                if ub.OnCollisionEnter then
                    pcall(ub.OnCollisionEnter, ub, ua)
                end
            end
        end

        local function endContact(a, b, contact)
            local ua = a:getUserData()
            local ub = b:getUserData()
            if ua and ub then
                if ua.OnCollisionExit then pcall(ua.OnCollisionExit, ua, ub) end
                if ub.OnCollisionExit then pcall(ub.OnCollisionExit, ub, ua) end
            end
        end

        world:setCallbacks(beginContact, endContact)
    end
    return world
end

--- @return love.World
function Physics.GetWorld()
    return EnsureWorld()
end

function Physics.Update(dt)
    if not world then return end
    world:update(dt)
end

function Physics.DrawCollisionMesh()
    if not world then return end

    love.graphics.push()
    love.graphics.setLineWidth(1)

    --- @param body love.Body
    for _, body in ipairs(world:getBodies()) do
        love.graphics.push()
        love.graphics.translate(body:getX() * Physics.PPM, body:getY() * Physics.PPM)
        love.graphics.rotate(body:getAngle())

        if body:getType() == "static" then
            love.graphics.setColor(0, 1, 0, 0.7)
        elseif body:getType() == "kinematic" then
            love.graphics.setColor(0, 1, 1, 0.7)
        else
            love.graphics.setColor(1, 0, 1, 0.7)
        end

        --- @param fixture love.Fixture
        for _, fixture in ipairs(body:getFixtures()) do
            --- @type love.Shape
            local shape = fixture:getShape()
            local shapeType = shape:getType()

            if shapeType == "polygon" then
                local pointsInPixels = {}
                --- @cast shape love.PolygonShape
                for i, v in ipairs({shape:getPoints()}) do
                    pointsInPixels[i] = v * Physics.PPM
                end
                love.graphics.polygon("line", pointsInPixels)

            elseif shapeType == "circle" then
                --- @cast shape love.CircleShape
                local cx_m, cy_m = shape:getPoint()
                local radius_m = shape:getRadius()
                love.graphics.circle("line", cx_m * Physics.PPM, cy_m * Physics.PPM, radius_m * Physics.PPM)
            end
        end

        love.graphics.pop()
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

return Physics
