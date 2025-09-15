local Physics = {}

local love_physics = love.physics

-- 初期重力をピクセル単位で設定（任意調整可能）
local gravityX, gravityY = 0, 9.81 * 64

local world = nil

local function ensureWorld()
    if not world then
        world = love_physics.newWorld(gravityX, gravityY, true)

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

function Physics.GetWorld()
    return ensureWorld()
end

function Physics.Update(dt)
    if not world then return end
    world:update(dt)
end

return Physics
