--- @class Component
local Component = ParallelEngine.Abstracts.Component
--- @class LogManager
local LogManager = ParallelEngine.LogManager
--- @class Physics
local Physics = ParallelEngine.Physics

--- @class PlayerController:Component
local PlayerController = Component:Extend()
PlayerController.__index = PlayerController
PlayerController.__name = "PlayerController"

-- 保存したいプロパティを宣言
PlayerController.Serializable = {"_enabled", "speed", "jumpHeight"}

function PlayerController.New(gameObjec, props)
    --- @class PlayerController
    local instance = setmetatable({}, PlayerController)
    instance:Init(gameObjec, props)
    return instance
end
--- @param gameObject GameObject
function PlayerController:Init(gameObject, props)
    self.super:Init()
    self.gameObject = gameObject

    self._enabled = props.enabled or true
    self.speed = props.speed or 5.0
    self.jumpHeight = props.jumpHeight or 1.0
    self.internalState = "running"

    self.ySpeedScale = math.random(-10, 10)
    self.xSpeedScale = math.random(-10, 10)
end

function PlayerController:Awake()
    --- @type RigidBody|nil
    self.rb = self.gameObject:GetComponent(ParallelEngine.Components.RigidBody)
    --- @type Collision|nil
    self.co = self.gameObject:GetComponent(ParallelEngine.Components.Collision)

    if not self.rb then
        LogManager.LogError(self.gameObject.name .. ": RigidBodyが見つかりません")
        return
    end
    if not self.co then
        LogManager.LogError(self.gameObject.name .. ": Collisionが見つかりません")
        return
    end

    self.co.OnCollisionEnter = function(other)
        other.gameObject.name = other.gameObject.name or "不明"
        print(self.gameObject.name .. " が " .. other.gameObject.name .. " と衝突しました")
    end

end

function PlayerController:Update(dt)
    if not self.rb then return end

    local velocityX, velocityY = self.rb.body:getLinearVelocity()
    local moveSpeed = 1

    if love.keyboard.isDown("d") then
        velocityX = velocityX + moveSpeed
    elseif love.keyboard.isDown("a") then
        velocityX = velocityX - moveSpeed
    elseif love.keyboard.isDown("w") then
        velocityY = velocityY - moveSpeed
    elseif love.keyboard.isDown("s") then
        velocityY = velocityY + moveSpeed
    elseif love.keyboard.isDown("space") then
        velocityY = velocityY -self.jumpHeight * 3
    else
        velocityX = 0
        velocityY = 0
    end

    self.rb:SetVelocity(velocityX, velocityY)
end

function PlayerController:__tostring()
    return string.format("enabled: %s, speed: %s, jumpHeight: %s", self._enabled, self.speed, self.jumpHeight)
end

return PlayerController