--- @class Component
local Component = ParallelEngine.Abstracts.Component
--- @class LogManager
local LogManager = ParallelEngine.LogManager

--- @class PlayerController:Component
local PlayerController = Component:Extend()
PlayerController.__index = PlayerController
PlayerController.__name = "PlayerController"

-- 保存したいプロパティを宣言
PlayerController.Serializable = {"_enabled", "speed", "jumpHeight"}

function PlayerController.New(props)
    --- @class PlayerController
    local instance = setmetatable({}, PlayerController)
    instance:Init(props)
    return instance
end

function PlayerController:Init(props)
    self.super:Init()
    self._enabled = props.enabled or true
    self.speed = props.speed or 5.0
    self.jumpHeight = props.jumpHeight or 10.0
    self.internalState = "running"

    self.ySpeedScale = math.random(-10, 10)
    self.xSpeedScale = math.random(-10, 10)
end

function PlayerController:Awake()
    self.rb = self.gameObject:GetComponent(ParallelEngine.Components.RigidBody)
    if not self.rb then
        LogManager.LogError(self.gameObject.name .. "RigidBodyが見つかりません")
    end
end

function PlayerController:Update(dt)
    if not self.rb then return end

    local velocityX, velocityY = self.rb.body:getLinearVelocity()
    local moveSpeed = 300

    if love.keyboard.isDown("d") then
        velocityX = moveSpeed
    elseif love.keyboard.isDown("a") then
        velocityX = -moveSpeed
    else
        velocityX = 0
    end

    self.rb:SetVelocity(velocityX, velocityY)
end

function PlayerController:__tostring()
    return string.format("enabled: %s, speed: %s, jumpHeight: %s", self._enabled, self.speed, self.jumpHeight)
end

return PlayerController