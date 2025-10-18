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

    -- HUD
    local uiMgr = ParallelEngine.UIManager.New()
    local hud = uiMgr:NewCanvas("GameHUD", { worldSpace = false, pivot = "topleft", debugHits = false })
    self.hud = hud
    self.hudLabels = {}

    local lblLeftGO = GameObject.New("HUD_Player1_Label")
    local defaultFont = love.graphics.newFont(20)
    local lblLeft = lblLeftGO:AddComponent(ParallelEngine.UI.Label, { x = 20, y = 20, text = tostring(self.playersPoints[1] or 0), font = defaultFont })
    if hud then
        hud:AddGameObject(lblLeftGO)
        table.insert(self.hudLabels, lblLeft)
    end

    local lblRightGO = GameObject.New("HUD_Player2_Label")
    local lblRight = lblRightGO:AddComponent(ParallelEngine.UI.Label, { x = w - 80, y = 20, text = tostring(self.playersPoints[2] or 0), font = defaultFont })
    if hud then
        hud:AddGameObject(lblRightGO)
        table.insert(self.hudLabels, lblRight)
    end

    self.countdownLabel = nil
    self.roundLabel = nil
    self.winnerLabel = nil
    if hud then
    local cdGO = GameObject.New("HUD_Countdown_Label")
    local bigFont = love.graphics.newFont(64)

    self.countdownLabel = cdGO:AddComponent(ParallelEngine.UI.Label, { x = w/2 - 20, y = h/2 - 80, text = "", font = bigFont })
    self.countdownLabel.visible = false
        hud:AddGameObject(cdGO)

        local ptsGO = GameObject.New("HUD_PressToStart_Label")
        local ptsFont = love.graphics.newFont(20)
        self.pressToStartLabel = ptsGO:AddComponent(ParallelEngine.UI.Label, { x = w/2 - 120, y = h - 60, text = "Press SPACE to Start", font = ptsFont })
        hud:AddGameObject(ptsGO)

        local roundGO = GameObject.New("HUD_Round_Label")
    local roundFont = love.graphics.newFont(28)
    self.roundLabel = roundGO:AddComponent(ParallelEngine.UI.Label, { x = w/2 - 30, y = 10, text = "Round 0", font = roundFont })
        hud:AddGameObject(roundGO)

        local winGO = GameObject.New("HUD_Winner_Label")
        local winnerFont = love.graphics.newFont(36)
        self.winnerLabel = winGO:AddComponent(ParallelEngine.UI.Label, { x = w/2 - 60, y = h/2 - 20, text = "", font = winnerFont })
        hud:AddGameObject(winGO)
    end

    self.lastCountdown = nil
    self.round = 0

    -- print("GameManager Awaked")
end

function GameManager:Start()
    canStart = true
    -- print("GameManager Started")
end

function GameManager:Update(dt)
    -- NOTE: always run HUD sync (countdown, press-to-start, winner) even if canStart is false.
    -- Only gate input-driven start logic behind canStart.
    -- ゲーム開始入力は canStart が true の時のみ有効
    if canStart then
        if not gameStarted then
            if love.keyboard.isDown("space") then
                self:StartGame()
            end
        end
    end

    local cd = ParallelEngine.LogManager.debugInfo["Countdown"]
    if cd ~= self.lastCountdown then
        self.lastCountdown = cd
        if self.countdownLabel then
            self.countdownLabel.text = cd or ""
            if self.countdownLabel.text == "" then
                self.countdownLabel.visible = false
            else
                self.countdownLabel.visible = true
            end
            local sw, sh = love.graphics.getDimensions()
            if self.countdownLabel.text ~= "" and self.countdownLabel.font then
                local tw = self.countdownLabel.font:getWidth(self.countdownLabel.text)
                local th = self.countdownLabel.font:getHeight()
                self.countdownLabel.x = (sw / 2) - (tw / 2)
                self.countdownLabel.y = (sh / 2) - (th / 2)
            else
                self.countdownLabel.x = sw + 1000
            end
        end
    end

    -- PressToStart は現在のカウントダウン値で判定（cd を直接使用）
    if self.pressToStartLabel then
        if cd and cd ~= "" then
            self.pressToStartLabel.visible = false
        else
            self.pressToStartLabel.visible = true
        end
    end

    -- Winner 表示を LogManager.debugInfo から同期する
    local winner = ParallelEngine.LogManager.debugInfo["Winner"]
    if self.winnerLabel then
        if winner and winner ~= "" then
            self.winnerLabel.text = winner
            self.winnerLabel.visible = true
        else
            -- 隠す（勝者情報が nil / 空文字のとき）
            self.winnerLabel.visible = false
        end
    end

    local sw, sh = love.graphics.getDimensions()
    if self.hudLabels and #self.hudLabels >= 2 then
        local left = self.hudLabels[1]
        local right = self.hudLabels[2]
        if left then
            left.x = 20
            left.y = 10
        end
        if right then
            right.y = 10
            if right.font then
                right.x = sw - 20 - right.font:getWidth(right.text or "")
            else
                right.x = sw - 80
            end
        end
    end
    if self.roundLabel and self.roundLabel.font then
        local rw = self.roundLabel.font:getWidth(self.roundLabel.text or "")
        self.roundLabel.x = (sw / 2) - (rw / 2)
        self.roundLabel.y = 10
    end
    if self.winnerLabel and self.winnerLabel.font then
        local ww = self.winnerLabel.font:getWidth(self.winnerLabel.text or "")
        self.winnerLabel.x = (sw / 2) - (ww / 2)
        self.winnerLabel.y = (sh / 2) - (self.winnerLabel.font:getHeight() / 2)
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

    if self.hudLabels and self.hudLabels[playerId] then
        self.hudLabels[playerId].text = tostring(self.players[playerId]:GetComponent(PlayerController).points)
    end

    TimerManager:After(1.0, function()
        self:StartGame()
    end)
end

--- ゲームの初回開始、または次のラウンドを開始する
function GameManager:StartGame()
    if not ballController then return end
    gameStarted = true

    self.round = (self.round or 0) + 1
    if self.roundLabel then
        self.roundLabel.text = "Round " .. tostring(self.round)
    end

    for _, player in pairs(self.players) do
        local pc = player:GetComponent(PlayerController)
        if pc then
            pc:Reset(DEFAULT_PLAYER_SIZE)
        end
    end
    ballController:ResetBall()
end

return GameManager