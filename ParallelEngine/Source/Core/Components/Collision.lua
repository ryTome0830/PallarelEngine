--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class RigidBody
local RigidBody = require("Core.Components.RigidBody")
--- @class Physics
local Physics = require("Core.Physics")

--- @class Collision:Component
local Collision = Component:Extend()
Collision.__index = Collision
Collision.__name = "Collision"

Collision.Serializable = {"_enabled", "size", "offset", "isSensor"}

function Collision.New(properties)
    local instance = setmetatable({}, Collision)
    instance:Init(properties)
    return instance
end

function Collision:Init(properties)
    self.super:Init()
    properties = properties or {}

    self.size = properties.size or {x=32, y=32}
    self.offset = properties.offset or {x=0, y=0}
    self.isSensor = properties.isSensor or false
    self._enabled = properties._enabled

    self.fixture = nil
    self.shape = nil
end

function Collision:CreateFixture()
    if self.fixture then return end

    --- @type RigidBody|nil
    local rb = nil
    if self.gameObject then
        rb = self.gameObject:GetComponent(RigidBody)
    end
    if not rb and self.gameObject then
        -- 自動で Rigidbody を作ってアタッチし、その参照を受け取る
        rb = self.gameObject:AddComponent(RigidBody, {mass=1.0, _enabled=true})
    end
    if rb and not rb.body then
        if rb.CreateBody then pcall(function() rb:CreateBody() end) end
    end
    if not rb or not rb.body then return end

    local hx = (self.size.x or 32) / 2
    local hy = (self.size.y or 32) / 2
    self.shape = love.physics.newRectangleShape(hx*2, hy*2)
    self.fixture = love.physics.newFixture(rb.body, self.shape)
    self.fixture:setSensor(self.isSensor)
    self.fixture:setUserData(self)
    -- RigidBody 側でも fixture を追跡しておく
    if rb and rb.shapes then table.insert(rb.shapes, self.fixture) end
end

function Collision:OnCollisionEnter(other)
    -- デフォルトは何もしない。ユーザーがオーバーライドして使う。
end

function Collision:OnCollisionExit(other)
end

function Collision:Update(dt)
    if not self:IsEnabled() then return end
    if not self.fixture then self:CreateFixture() end
end

function Collision:Destroy()
    if self.fixture then pcall(function() self.fixture:destroy() end) end
    self.fixture = nil
    self.shape = nil
end

function Collision:Dump()
    return Component.Dump(self)
end

return Collision
