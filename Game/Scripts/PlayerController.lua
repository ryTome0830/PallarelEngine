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
PlayerController.Serializable = {"_enabled", "speedScale"}

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

    self.playerId = props.playerId or 1
    self.speedScale = props.speedScale or 50
    self.velocityY = 0

    self.points = 0

    self.ballRb = nil

    self.shrinkFactor = 0.9
    self.minHeight = 80
    self.collisionNumber = 0
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

    self.co.OnCollisionEnter = function(owner, other)
        if not self.ballRb then self.ballRb = other.gameObject and other.gameObject:GetComponent(ParallelEngine.Components.RigidBody) end
        if other.gameObject.name == "Ball" and self.ballRb then
            -- 1. 衝突点を計算 (-1.0 から 1.0)
            local playerY = self.gameObject.transform.position.y
            local ballY = other.gameObject.transform.position.y
            local playerHeight = self.gameObject.transform.scale.y
            local relativeImpactY = (playerY - ballY) / (playerHeight / 2)
            -- 値を -1 と 1 の間に固定する
            relativeImpactY = math.max(-1, math.min(1, relativeImpactY))

            -- 2. 衝突点から反射角度を計算 (-45度から45度へマッピング)
            local bounceAngle = relativeImpactY * (math.pi / 4) -- pi/4 は45度

            -- 3. プレイヤーの位置に応じてボールの水平方向を決める
            local directionX = 1
            if self.gameObject.transform.position.x > other.gameObject.transform.position.x then
                -- プレイヤーが右側にいる場合、ボールは左へ飛ぶ
                directionX = -1
            end

            -- 4. 新しい速度ベクトルを計算
            local ballSpeed = self.ballRb:GetVelocity() * self.co.restitution
            local vx = ballSpeed * math.cos(bounceAngle) * directionX
            local vy = ballSpeed * math.sin(bounceAngle) * -1

            -- 5. ボールに新しい速度を適用
            self.ballRb:SetVelocity(vx, vy)
            LogManager.AddDebugInfo("BallVelocity", string.format("Vx: %.2f, Vy: %.2f", vx, vy))

            -- サイズ変更
            self.collisionNumber = self.collisionNumber + 1
            -- 3回に1回サイズを縮小
            if self.collisionNumber % 3 == 0 then
                print("Player " .. self.playerId .. " paddle shrinks!")

                local t = self.gameObject.transform
                local currentScale = t.scale
                t:SetScale(ParallelEngine.Vector2.New(currentScale.x, currentScale.y * self.shrinkFactor))
                self.rb = nil
            end
        end
    end
end

function PlayerController:Update(dt)
    if not self.rb then self.rb = self.gameObject:GetComponent(ParallelEngine.Components.RigidBody) return end
    local velocityY = 0

    if love.keyboard.isDown("w") then
        if self.gameObject.transform.position.y - self.gameObject.transform.scale.y / 2 <= 0 then
            velocityY = 0
        else
            velocityY = -self.speedScale
        end
    elseif love.keyboard.isDown("s") then
        if self.gameObject.transform.position.y + self.gameObject.transform.scale.y / 2 >= love.graphics.getHeight() then
            velocityY = 0
        else
            velocityY = self.speedScale
        end
    end

    self.rb:SetVelocity(0, velocityY)
end

function PlayerController:AddPoint()
    self.points = self.points + 1
    -- >> DEV
    print("Player " .. self.playerId .. " scored! Total points: " .. self.points)
end

--- @param paddleSize {x:integer, y:integer}
function PlayerController:Reset(paddleSize)
    if paddleSize then
        self.gameObject.transform:SetScale(ParallelEngine.Vector2.New(paddleSize.x, paddleSize.y))
    end
end

function PlayerController:__tostring()
    return "PlayerController"
end

return PlayerController