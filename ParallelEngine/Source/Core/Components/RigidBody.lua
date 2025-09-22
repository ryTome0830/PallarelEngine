--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class Physics
local Physics = require("Core.Physics")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class RigidBodyProperties
--- @field _enabled? boolean
--- @field mass? number
--- @field bodyType? love.BodyType
--- @field velocity? {x: number, y: number}
--- @field fixedRotation? boolean

--- @class RigidBody:Component
local RigidBody = Component:Extend()
RigidBody.__index = RigidBody
RigidBody.__name = "RigidBody"

RigidBody.Serializable = {"_enabled", "mass", "bodyType", "velocity", "fixedRotation"}


local PPM = Physics.PPM

--- @param gameObject GameObject
--- @param properties RigidBodyProperties
function RigidBody.New(gameObject, properties)
    local instance = setmetatable({}, RigidBody)
    instance:Init(gameObject, properties)

    return instance
end

--- @param gameObject GameObject
--- @param properties RigidBodyProperties
function RigidBody:Init(gameObject, properties)
    self.super:Init()
    properties = properties or {}

    self.gameObject = gameObject
    self.mass = properties.mass or 1.0
    self.bodyType = properties.bodyType or "dynamic"
    self._enabled = properties._enabled
    self.velocity = properties.velocity or {x = 0, y = 0}
    self.fixedRotation = properties.fixedRotation or false
    self.body = nil
    self.shapes = {}
end

function RigidBody:Awake()
    if self.body then return end
    local world = Physics.GetWorld()

    if not world then return end
    local t = self.gameObject and self.gameObject.transform
    local x, y = 0, 0
    if t and t.position then
        x, y = t.position.x / PPM, t.position.y / PPM
    end
    self.body = love.physics.newBody(world, x, y, self.bodyType)
    self.body:setMass(self.mass)
    self.body:setFixedRotation(self.fixedRotation)
    self.body:setUserData(self)

    if self.velocity then
        self.body:setLinearVelocity(self.velocity.x or 0, self.velocity.y or 0)
    end
end

function RigidBody:Update(dt)
    if not self:IsEnabled() or not self.body then return end

    local x, y = self.body:getPosition()
    local angle = self.body:getAngle()
    if self.gameObject and self.gameObject.transform then
        self.gameObject.transform.position.x = x * PPM
        self.gameObject.transform.position.y = y * PPM
        self.gameObject.transform.rotation = angle
    end

end

function RigidBody:Destroy()
    if self.body then
        for _, f in ipairs(self.shapes) do
            if f and not f:isDestroyed() then pcall(function() f:destroy() end) end
        end
        pcall(function() self.body:destroy() end)
        self.body = nil
    end
    self.gameObject = nil
    self.shapes = nil
end

function RigidBody:ApplyForce(fx, fy)
    if not self.body then return end
    self.body:applyForce(fx or 0, fy or 0)
end

--- @param vx number x軸の速度
--- @param vy number y軸の速度
function RigidBody:SetVelocity(vx, vy)
    if not self.body then return end
    self.body:setLinearVelocity(vx or 0, vy or 0)
end

--- @param px number x座標
--- @param py number y座標
function RigidBody:SetPosition(px, py)
    if not self.body then return end
    self.body:setPosition(px / PPM, py / PPM)
    if self.gameObject and self.gameObject.transform then
        self.gameObject.transform.position.x = px
        self.gameObject.transform.position.y = py
    end
end

--- 速度の大きさを取得
--- @return number
function RigidBody:GetVelocity()
    if not self.body then return 0 end
    local vx, vy = self.body:getLinearVelocity()
    return math.sqrt(vx ^ 2 + vy ^ 2)
end


return RigidBody