--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class Pyhics
local Physics = require("Core.Physics")

--- @class RigidBody:Component
local RigidBody = Component:Extend()
RigidBody.__index = RigidBody
RigidBody.__name = "RigidBody"

RigidBody.Serializable = {"_enabled", "mass", "bodyType"}

function RigidBody.New(properties)
    local instance = setmetatable({}, RigidBody)
    instance:Init(properties)
    return instance
end

function RigidBody:Init(properties)
    self.super:Init()
    properties = properties or {}

    self.mass = properties.mass or 1.0
    self.bodyType = properties.bodyType or "dynamic" -- dynamic, static, kinematic
    self._enabled = properties._enabled

    self.body = nil
    self.shapes = {}
end

function RigidBody:CreateBody()
    if self.body then return end
    local world = Physics.GetWorld()
    if not world then return end

    local t = self.gameObject and self.gameObject.transform
    local x, y = 0, 0
    if t and t.position then x, y = t.position.x, t.position.y end

    self.body = love.physics.newBody(world, x, y, self.bodyType)
    self.body:setMass(self.mass)
    self.body:setUserData(self)
end

function RigidBody:ApplyForce(fx, fy)
    if not self.body then return end
    self.body:applyForce(fx or 0, fy or 0)
end

function RigidBody:Update(dt)
    if not self:IsEnabled() then return end
    if not self.body then self:CreateBody() end
    if not self.body then return end

    -- sync transform with physics body
    local x, y = self.body:getPosition()
    if self.gameObject and self.gameObject.transform then
        self.gameObject.transform.position.x = x
        self.gameObject.transform.position.y = y
    end
end

function RigidBody:Destroy()
    if self.body then
        -- destroy attached fixtures
        for _, f in ipairs(self.shapes) do
            if f and not f:isDestroyed() then pcall(function() f:destroy() end) end
        end
        pcall(function() self.body:destroy() end)
        self.body = nil
    end
end

function RigidBody:Dump()
    return Component.Dump(self)
end

return RigidBody
