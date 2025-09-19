--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class RigidBody
local RigidBody = require("Core.Components.RigidBody")
--- @class Physics
local Physics = require("Core.Physics")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class CollisionProperties
--- @field _enabled? boolean
--- @field size? {x: number, y: number}
--- @field offset? {x: number, y: number}
--- @field isSensor? boolean
--- @field friction? number
--- @field restitution? number

--- @class Collision:Component
local Collision = Component:Extend()
Collision.__index = Collision
Collision.__name = "Collision"

Collision.Serializable = {"_enabled", "size", "offset", "isSensor", "friction", "restitution"}

local PPM = Physics.PPM

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

    -- Uninitialized
    self.gameObject = gameObject
    self.fixture = nil
    self.shape = nil

    -- Serializable
    self.size = properties.size or {x=self.gameObject.transform.scale.x, y=self.gameObject.transform.scale.y} or {x=32, y=32}
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

    if not rb then
        LogManager.LogError("Collision component requires a RigidBody component on '" .. self.gameObject.name .. "'.")
        return
    end

    if not rb.body then
        LogManager.LogError("Failed to create fixture: RigidBody's physics body is not available. Check initialization order.")
        return
    end

    local width_m = (self.size.x or 32) / PPM
    local height_m = (self.size.y or 32) / PPM
    local offsetX_m = (self.offset.x or 0) / PPM
    local offsetY_m = (self.offset.y or 0) / PPM

    if width_m <= 0 or height_m <= 0 then
        LogManager.LogError(string.format(
            "Invalid collision shape size for '%s'. Width and height must be positive. Got size: (%f, %f)",
            self.gameObject.name, self.size.x, self.size.y
        ))
        return
    end

    self.shape = love.physics.newRectangleShape(offsetX_m, offsetY_m, width_m, height_m)
    self.fixture = love.physics.newFixture(rb.body, self.shape)
    self.fixture:setSensor(self.isSensor)
    self.fixture:setUserData(self)
    self.fixture:setFriction(self.friction or 0)
    self.fixture:setRestitution(self.restitution or 1)

    if rb.shapes then
        table.insert(rb.shapes, self.fixture)
    end
end

--- @param other Collision
function Collision:OnCollisionEnter(other)
end

--- @param other Collision
function Collision:OnCollisionExit(other)
end

function Collision:Update(dt)
end

function Collision:Destroy()
    if self.fixture then
        pcall(function() self.fixture:destroy() end)
    end
    self.fixture = nil
    self.shape = nil
end

--- デバッグ用: コリジョンの矩形を描画
function Collision:Draw()
    if not self:IsEnabled() then return end
    if not self.gameObject or not self.gameObject.transform then return end

    local t = self.gameObject.transform
    local w = self.size and self.size.x or t.scale.x
    local h = self.size and self.size.y or t.scale.y
    local ox = self.offset and self.offset.x or 0
    local oy = self.offset and self.offset.y or 0

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.push()
    love.graphics.translate(t.position.x, t.position.y)
    love.graphics.rotate(t.rotation)
    love.graphics.rectangle("fill", -w/2 + ox, -h/2 + oy, w, h)
    love.graphics.pop()
    love.graphics.setColor(1,1,1,1)
end


return Collision