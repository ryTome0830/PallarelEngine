local ParallelEngine = require("ParallelEngine")
-- TimerManagerを読み込む
local TimerManager = ParallelEngine.Utils.TimerManager.New()

--- @class PlayerController
local PlayerController = require("Game.Scripts.PlayerController")

--- @class BallController:Component
local BallController = ParallelEngine.Abstracts.Component:Extend()
BallController.__index = BallController
BallController.__name = "BallController"

function BallController.New(gameObject, props)
    --- @class BallController
    local instance = setmetatable({}, BallController)
    instance:Init(gameObject, props)
    return instance
end

-- Initialize BallController with players and ball
function BallController:Init(gameObject, props)
    --- @type GameObject
    self.gameObject = gameObject
    self.onEnterEvent = props.event
    self.maxSpeed = props.maxSpeed
end

function BallController:Awake()
    -- >> DEV
    -- print("BallController Awake")
    --- @type RigidBody|nil
    self.rb = self.gameObject:GetComponent(ParallelEngine.Components.RigidBody)
    if not self.rb then
        error("BallController: RigidBody component not found on ball")
    end
    --- @type Collision|nil
    self.co = self.gameObject:GetComponent(ParallelEngine.Components.Collision)
    if not self.co then
        error("BallController: Collision component not found on ball")
    end

    self.co.OnCollisionEnter = function(owner, other)
        local otherName = other.gameObject.name
        if otherName == "WallLeft" then
            self.onEnterEvent(1)
        elseif otherName == "WallRight" then
            self.onEnterEvent(2)
        else
            local vx, vy = self.rb.body:getLinearVelocity()
            if otherName == "WallUp" and vy < 0 then
                vy = -vy
            elseif otherName == "WallDown" and vy > 0 then
                vy = -vy
            end
            self.rb:SetVelocity(vx, vy)
        end
    end
end

function BallController:ResetBall()
    local w, h = love.graphics.getDimensions()
    self.rb:SetVelocity(0, 0)
    self.rb:SetPosition(w / 2, h / 2)
    ParallelEngine.LogManager.AddDebugInfo("Countdown", "3")
    TimerManager:Sequence({
        {1.0, function()
            ParallelEngine.LogManager.AddDebugInfo("Countdown", "2")
        end},
        {1.0, function()
            ParallelEngine.LogManager.AddDebugInfo("Countdown", "1")
        end},
        {1.0, function()
            ParallelEngine.LogManager.AddDebugInfo("Countdown", nil)
            local direction = math.random(0, 1) == 0 and -1 or 1
            local angle = math.random() * 2 * (math.pi / 6) - (math.pi / 6)
            local speed = 80
            local vx = math.cos(angle) * speed * direction
            local vy = math.sin(angle) * speed
            self.rb:SetVelocity(vx, vy)
        end}
    })
end

function BallController:Update(dt)
    if not self.rb then return end

    -- ボールの速度が最大速度を超えないように制限
    local vx, vy = self.rb.body:getLinearVelocity()
    local speed = math.sqrt(vx ^ 2 + vy ^ 2)
    if speed > self.maxSpeed then
        local scale = self.maxSpeed / speed
        vx = vx * scale
        vy = vy * scale
        self.rb:SetVelocity(vx, vy)
    end
    ParallelEngine.LogManager.AddDebugInfo("BallLinerVelocity: ",  speed)
end

return BallController