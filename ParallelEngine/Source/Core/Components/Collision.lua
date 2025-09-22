--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class RigidBody
local RigidBody = require("Core.Components.RigidBody")
--- @class Physics
local Physics = require("Core.Physics")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- @alias CollisionShapeType
--- | "rectangle"
--- | "circle"
--- | "polygon"


--- @class CollisionProperties
--- @field _enabled? boolean
--- @field shapeType? CollisionShapeType
--- @field size? {x: number, y: number}
--- @field radius? number
--- @field vertices? number[]
--- @field offset? {x: number, y: number}
--- @field isSensor? boolean
--- @field friction? number
--- @field restitution? number

--- @class Collision:Component
local Collision = Component:Extend()
Collision.__index = Collision
Collision.__name = "Collision"

Collision.Serializable = {"_enabled", "shapeType", "size", "radius", "vertices", "offset", "isSensor", "friction", "restitution"}

local PPM = Physics.PPM
local defaultSize = PPM * 4

--- @param gameObject GameObject
--- @param properties CollisionProperties
function Collision.New(gameObject, properties)
    local instance = setmetatable({}, Collision)
    instance:Init(gameObject, properties)
    return instance
end

--- @param gameObject GameObject
--- @param properties CollisionProperties
function Collision:Init(gameObject, properties)
    self.super:Init()
    properties = properties or {}

    -- UnSerializable
    self.gameObject = gameObject
    self.fixture = nil
    self.shape = nil
    self.pendingResize = nil

    -- Serializable
    self.shapeType = properties.shapeType or "rectangle"
    if self.shapeType == "rectangle" then
        self.size = properties.size or {x=self.gameObject.transform.scale.x, y=self.gameObject.transform.scale.y} or {x=defaultSize, y=defaultSize}
    elseif self.shapeType == "circle" then
        self.radius = properties.radius or (self.gameObject.transform.scale.x / 2) or (defaultSize / 2)
    elseif self.shapeType == "polygon" then
        self.vertices = properties.vertices or {
            {0,0}, {defaultSize,0}, {defaultSize, defaultSize}, {0,defaultSize}
        }
    end
    self.offset = properties.offset or {x=0, y=0}
    self.friction = properties.friction or 0
    self.restitution = properties.restitution or 1
    if properties.isSensor == nil then
        self.isSensor = false
    else
        self.isSensor = properties.isSensor
    end
    if properties._enabled == nil then
        self._enabled = true
    else
        self._enabled = properties._enabled
    end
end

function Collision:Start()
    if self.fixture then return end

    --- @type RigidBody|nil
    local rb = self.gameObject and self.gameObject:GetComponent(RigidBody)
    if not rb or not rb.body then
        LogManager.LogError("Collision component requires a RigidBody component on '" .. self.gameObject.name .. "'.")
        return
    end

    self.shape = self:CreateShape(self.shapeType)
    if not self.shape then
        LogManager.LogError("Failed to create collision shape for '" .. self.gameObject.name .. "'.")
        return
    end

    self.fixture = love.physics.newFixture(rb.body, self.shape)
    self.fixture:setSensor(self.isSensor)
    self.fixture:setUserData(self)
    self.fixture:setFriction(self.friction or 0)
    self.fixture:setRestitution(self.restitution or 1)

    if rb.shapes then
        table.insert(rb.shapes, self.fixture)
    end

    if self.gameObject then
        local t = self.gameObject.transform
        t.onScaleChanged:Subscribe(function (transform)
            LogManager.Log("Collision: Resizing due to Transform scale change.")
            -- self:Resize({x=transform.scale.x, y=transform.scale.y})
            self.pendingResize = {x=transform.scale.x, y=transform.scale.y}
        end)
    end
end

--- @private
function Collision:CreateShape(shapeType)
    if self.shapeType == "rectangle" then
        local width_m = self.size.x / PPM
        local height_m = self.size.y / PPM
        local offsetX_m = self.offset.x / PPM
        local offsetY_m = self.offset.y / PPM

        if width_m <= 0 or height_m <= 0 then
            LogManager.LogError(string.format(
                "Invalid collision shape size for '%s'. Width and height must be positive. Got size: (%f, %f)",
                self.gameObject.name, self.size.x, self.size.y
            ))
            return nil
        end

        return love.physics.newRectangleShape(offsetX_m, offsetY_m, width_m, height_m)
    elseif self.shapeType == "circle" then
        local radius_m = self.radius / PPM
        local offsetX_m = self.offset.x / PPM
        local offsetY_m = self.offset.y / PPM
        if radius_m <= 0 then
            LogManager.LogError(string.format(
                "Invalid collision shape size for '%s'. Radius must be positive. Got radius: %f",
                self.gameObject.name, radius_m
            ))
            return nil
        end
        return love.physics.newCircleShape(offsetX_m, offsetY_m, radius_m)
    elseif self.shapeType == "polygon" then
        -- vertices: {{x1, y1}, {x2, y2}, ...}
        if not self.vertices or #self.vertices < 3 then
            LogManager.LogError("Polygon shape requires at least 3 vertices.")
            return nil
        end
        local verts = {}
        for i, v in ipairs(self.vertices) do
            -- offset考慮
            local x = (v[1] + (self.offset.x or 0)) / PPM
            local y = (v[2] + (self.offset.y or 0)) / PPM
            table.insert(verts, x)
            table.insert(verts, y)
        end
        return love.physics.newPolygonShape(verts)
    end
end

function Collision:Update(dt)
    -- Resize
    if self.pendingResize then
        self:Resize(self.pendingResize)
        self.pendingResize = nil
    end
end

function Collision:Destroy()
    if self.fixture then
        pcall(function() self.fixture:destroy() end)
    end
    self.gameObject = nil
    self.size = nil
    self.vertices = nil
    self.offset = nil
    self.fixture = nil
    self.shape = nil
end

--- デバッグ用: コリジョンの矩形を描画
function Collision:Draw()
    if not self:IsEnabled() then return end
    if not self.gameObject or not self.gameObject.transform then return end

    local t = self.gameObject.transform
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.push()
    love.graphics.translate(t.position.x, t.position.y)
    love.graphics.rotate(t.rotation)

    if self.shapeType == "rectangle" then
        local w = self.size and self.size.x or t.scale.x
        local h = self.size and self.size.y or t.scale.y
        local ox = self.offset and self.offset.x or 0
        local oy = self.offset and self.offset.y or 0
        love.graphics.rectangle("fill", -w/2 + ox, -h/2 + oy, w, h)
    elseif self.shapeType == "circle" then
        local r = self.radius or (self.size and self.size.x/2 or 16)
        local ox = self.offset and self.offset.x or 0
        local oy = self.offset and self.offset.y or 0
        love.graphics.circle("fill", ox, oy, r)
    elseif self.shapeType == "polygon" then
        local verts = {}
        for i, v in ipairs(self.vertices) do
            local x = v[1] + (self.offset and self.offset.x or 0)
            local y = v[2] + (self.offset and self.offset.y or 0)
            table.insert(verts, x)
            table.insert(verts, y)
        end
        love.graphics.polygon("fill", verts)
    end

    love.graphics.pop()
    love.graphics.setColor(1,1,1,1)
end

--- @private
--- @param newSize {x: number, y: number}|number
--- @overload fun(newSize: {x: number, y: number})
--- @overload fun(newSieze: number)
function Collision:Resize(newSize)
    if not self.fixture then
        LogManager.LogWarning("Collision:Resize called before fixture is created.")
        return
    end

    if self.shapeType == "rectangle" and type(newSize) == "table" then
        self.size = {x=newSize.x, y=newSize.y}
    elseif self.shapeType == "circle" and type(newSize) == "number" then
        self.radius = newSize
    else
        LogManager.LogWarning("Collision:Resize called with invalid size for shapeType '" .. self.shapeType .. "'.")
    end

    local rb = self.gameObject:GetComponent(RigidBody)
    if not rb or not rb.body then
        LogManager.LogError("Collision:Resize requires a valid RigidBody component on '" .. self.gameObject.name .. "'.")
        return
    end
    self.fixture:destroy()
    self.shape = self:CreateShape(self.shapeType)
    if not self.shape then
        LogManager.LogError("Failed to recreate collision shape for '" .. self.gameObject.name .. "'.")
        return
    end

    self.fixture = love.physics.newFixture(rb.body, self.shape)
    self.fixture:setSensor(self.isSensor)
    self.fixture:setUserData(self)
    self.fixture:setFriction(self.friction or 0)
    self.fixture:setRestitution(self.restitution or 1)
end


--- @param owner Collision
--- @param other Collision
function Collision:OnCollisionEnter(owner, other)
end

--- @param owner Collision
--- @param other Collision
function Collision:OnCollisionExit(owner, other)
end

return Collision