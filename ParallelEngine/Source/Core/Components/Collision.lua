--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class RigidBody
local RigidBody = require("Core.Components.RigidBody")
--- @class Physics
local Physics = require("Core.Physics")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class Collision:Component
local Collision = Component:Extend()
Collision.__index = Collision
Collision.__name = "Collision"

Collision.Serializable = {"_enabled", "size", "offset", "isSensor"}

--- @param gameObject GameObject
--- @param properties CollisionPropertiesDefinition
function Collision.New(gameObject, properties)
    local instance = setmetatable({}, Collision)
    instance:Init(gameObject, properties)
    return instance
end

--- @param gameObject GameObject
--- @param properties CollisionPropertiesDefinition
function Collision:Init(gameObject, properties)
    self.super:Init()
    properties = properties or {}

    self.gameObject = gameObject
    self.size = properties.size or {x=self.gameObject.transform.scale.x, y=self.gameObject.transform.scale.y} or {x=32, y=32}
    self.offset = properties.offset or {x=0, y=0}
    self.isSensor = properties.isSensor or false
    self._enabled = properties._enabled

    self.fixture = nil
    self.shape = nil
end

-- StartでFixtureを生成するように変更
function Collision:Start()
    if self.fixture then return end

    --- @type RigidBody|nil
    local rb = self.gameObject and self.gameObject:GetComponent(RigidBody)

    -- RigidBodyが見つからない場合、自動で追加する
    if not rb and self.gameObject then
        LogManager.LogWarning("Collision component requires a RigidBody component. Automatically adding one.")
        rb = self.gameObject:AddComponent(RigidBody, {mass=1.0, _enabled=true})
    end

    -- RigidBodyまたはそのBodyが存在しない場合はエラー
    if not rb or not rb.body then
        LogManager.LogError("Failed to create fixture: RigidBody or its physics body is not available.")
        return
    end

    local hx = (self.size.x or 32) / 2
    local hy = (self.size.y or 32) / 2
    self.shape = love.physics.newRectangleShape(hx*2, hy*2)
    self.fixture = love.physics.newFixture(rb.body, self.shape)
    self.fixture:setSensor(self.isSensor)
    self.fixture:setUserData(self)
    -- RigidBody 側でも fixture を追跡しておく
    if rb.shapes then
        table.insert(rb.shapes, self.fixture)
    end
end

function Collision:OnCollisionEnter(other)
    -- デフォルトは何もしない。ユーザーがオーバーライドして使う。
end

function Collision:OnCollisionExit(other)
end

function Collision:Destroy()
    if self.fixture then
        pcall(function() self.fixture:destroy() end)
    end
    self.fixture = nil
    self.shape = nil
end

function Collision:Dump()
    return Component.Dump(self)
end


return Collision