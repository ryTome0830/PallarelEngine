--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class TimerManager
local TimerManager = {}
TimerManager.__index = TimerManager
TimerManager.__name = "TimerManager"

--- シングルトンインスタンス
local SingletonInstance = nil

--- TimerManagerのインスタンスを返す
--- @return TimerManager
function TimerManager.New()
    if not SingletonInstance then
        local instance = setmetatable({}, TimerManager)
        instance:Init()
        SingletonInstance = instance
    end
    return SingletonInstance
end

--- 初期化
function TimerManager:Init()
    --- @type table<thread, boolean>
    self.timers = {}
end

--- 指定秒数後にコールバックを実行する
--- @param duration number
--- @param onComplete fun():nil
--- @return thread
function TimerManager:After(duration, onComplete)
    local co = coroutine.create(function()
        local timer = duration
        while timer > 0 do
            local dt = coroutine.yield()
            timer = timer - dt
        end
        if onComplete then
            onComplete()
        end
    end)

    self.timers[co] = true
    return co
end

--- @param sequence table
--- @return thread
function TimerManager:Sequence(sequence)
    local co = coroutine.create(function()
        for _, step in ipairs(sequence) do
            local duration = step[1]
            local onComplete = step[2]

            if duration > 0 then
                local timer = duration
                while timer > 0 do
                    local dt = coroutine.yield()
                    timer = timer - dt
                end
            end

            -- Execute the action
            if onComplete then
                onComplete()
            end
        end
    end)

    self.timers[co] = true
    return co
end

--- タイマーをキャンセル
--- @param co thread
function TimerManager:Cancel(co)
    if self.timers[co] then
        self.timers[co] = nil
    end
end

--- タイマー更新
--- @param dt number
function TimerManager:Update(dt)
    if next(self.timers) == nil then return end
    for co, _ in pairs(self.timers) do
        local status, err = coroutine.resume(co, dt)

        if not status then
            LogManager.LogError("[TimerManager] Error: " .. tostring(err))
            self.timers[co] = nil
        elseif coroutine.status(co) == "dead" then
            self.timers[co] = nil
        end
    end
end

--- すべてのタイマーを停止
function TimerManager:StopAll()
    --- すべてのコルーチンを破棄
    for co, _ in pairs(self.timers) do
        self.timers[co] = nil
    end
    self.timers = {}
end

return TimerManager