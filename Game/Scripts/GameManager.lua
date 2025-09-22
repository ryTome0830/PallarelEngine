--- @class GameObject
local GameObject = ParallelEngine.GameObject
--- @class Vector2
local Vector2 = ParallelEngine.Vector2
--- @class RigidBody
local RigidBody = ParallelEngine.Components.RigidBody
--- @class Collision
local Collision = ParallelEngine.Components.Collision
--- @class SpriteRenderer
local SpriteRenderer = ParallelEngine.Components.SpriteRenderer
--- @class TimerManager
local TimerManager = ParallelEngine.Utils.TimerManager.New()

--- @class PlayerController
local PlayerController = require("Game.Scripts.PlayerController")
--- @class BallController
local BallController = require("Game.Scripts.BallController")

--- @class GameManager:Component
local GameManager = ParallelEngine.Abstracts.Component:Extend()
GameManager.__index = GameManager
GameManager.__name = "GameManager"

local SingletonInstance = nil


--- @return GameManager
function GameManager.New(gameObject, props)
    if SingletonInstance then
        return SingletonInstance
    end
    --- @class GameManager
    local instance = setmetatable({}, GameManager)
    instance:Init(gameObject)
    SingletonInstance = instance
    return SingletonInstance
end

function GameManager:Init(gameObject)
    self.gameObject = gameObject
    self.players = {}
    self.ball = nil
    self.playersPoints = {0, 0}
end

--- @type BallController|nil
local ballController = nil
--- @type boolean
local gameStarted = false
--- @type boolean
local canStart = false
--- @type {x:integer, y:integer}
local DEFAULT_PLAYER_SIZE = {x = 10, y = 300}

function GameManager:Awake()

    -- 重力を無効化
    ParallelEngine.Physics.gravityX = 0
    ParallelEngine.Physics.gravityY = 0
    -- 画面サイズを取得
    local w, h, _ = love.graphics.getDimensions()


    -- 壁を生成
    local wallThickness = 40
    local offset = 10
    local walls = {
        WallUp      = GameObject.New("WallUp",      Vector2.New(w/2, -wallThickness/2+offset), 0, Vector2.New(w, wallThickness)),
        WallDown    = GameObject.New("WallDown",    Vector2.New(w/2, h+wallThickness/2-offset), 0, Vector2.New(w, wallThickness)),
        WallLeft    = GameObject.New("WallLeft",    Vector2.New(-wallThickness/2+offset, h/2), 0, Vector2.New(wallThickness, h)),
        WallRight   = GameObject.New("WallRight",   Vector2.New(w+wallThickness/2-offset, h/2), 0, Vector2.New(wallThickness, h))
    }

    for _, wall in pairs(walls) do
        wall:AddComponent(RigidBody, {mass=10.0, bodyType="static"})
        wall:AddComponent(Collision, {})
        wall:AddComponent(SpriteRenderer, { color={0.5,0.5,0.5,1} })
    end

    -- センターラインを生成
    local centerLine = GameObject.New("CenterLine", Vector2.New(w/2, h/2), 0, Vector2.New(4, h))
    centerLine:AddComponent(SpriteRenderer, { color={0.8,0.8,0.8,0.3} })

    -- Playerをインスタンス化
    local spawnPoint = {
        Vector2.New(50, h/2),
        Vector2.New(w-50, h/2)
    }
    local colorPresets = {
        {0.2, 0.6, 1.0, 1.0},   -- Blue
        {1.0, 0.4, 0.4, 1.0}    -- Red
    }
    for i = 1, 2, 1 do
        local player = ParallelEngine.GameObject.New(
            "Player" .. i,
            spawnPoint[i],
            0,
            Vector2.New(DEFAULT_PLAYER_SIZE.x, DEFAULT_PLAYER_SIZE.y)
        )
        player:AddComponent(RigidBody, {mass=1.0, bodyType="kinematic", fixedRotation=true})
        player:AddComponent(Collision, {restitution=1.02})
        player:AddComponent(SpriteRenderer, {color=colorPresets[i]})
        player:AddComponent(PlayerController, {playerId=i, speedScale=100})
        table.insert(self.players, player)
    end

    -- Ballをインスタンス化
    self.ball = ParallelEngine.GameObject.New("Ball", Vector2.New(w/2, h/2), 0, Vector2.New(16, 16))
    self.ball:AddComponent(RigidBody, {mass=1.0, bodyType="dynamic"})
    self.ball:AddComponent(Collision, {shapeType="circle", radius=8})
    self.ball:AddComponent(SpriteRenderer, {})
    ballController = self.ball:AddComponent(BallController, {maxSpeed = 150, event = function (playerID) self:OnBallEvent(playerID) end})

    -- print("GameManager Awaked")
end

function GameManager:Start()
    canStart = true
    -- print("GameManager Started")
end

function GameManager:Update(dt)
    if not canStart then return end
    -- ゲームが始まっていない時だけスペースキーの入力を待つ
    if not gameStarted then
        if love.keyboard.isDown("space") then
            self:StartGame()
        end
    end
end

--- ボールが壁に当たった時に呼ばれるイベントハンドラ
function GameManager:OnBallEvent(playerId)
    gameStarted = false
    if self.ball then
        local rb = self.ball:GetComponent(RigidBody)
        if rb then
            rb:SetVelocity(0, 0)
        end
    end
    local pc = self.players[playerId]:GetComponent(PlayerController)
    if pc then
        pc:AddPoint()
        if pc.points >= 3 then
            print("Player " .. playerId .. " wins the game!")
            ParallelEngine.LogManager.AddDebugInfo("Winner", "Player " .. playerId .. " Wins!")
            canStart = false
            return
        end
    end

    TimerManager:After(1.0, function()
        self:StartGame()
    end)
end

--- ゲームの初回開始、または次のラウンドを開始する
function GameManager:StartGame()
    if not ballController then return end
    gameStarted = true

    for _, player in pairs(self.players) do
        local pc = player:GetComponent(PlayerController)
        if pc then
            pc:Reset(DEFAULT_PLAYER_SIZE)
        end
    end
    ballController:ResetBall()
end

return GameManager