--- @class LogManager
local LogManager = {}
LogManager.__name = "LogManager"

--- @enum LogLevels
local LogLevels = {
    LOG = 1,
    WARN = 2,
    ERROR = 3,
    SUCCESS = 4,
}

--- @enum LogColors
local LogColors = {
    [LogLevels.LOG] = "\27[37m",      -- White
    [LogLevels.WARN] = "\27[33m",     -- Yellow
    [LogLevels.ERROR] = "\27[31m",    -- Red
    [LogLevels.SUCCESS] = "\27[32m",  -- Green
}

local reset = "\27[0m"

local function colorPrint(level, message)
    local color = LogColors[level] or LogColors[LogLevels.LOG]
    print(string.format("%s%s%s", color, message, reset))
end

local MAX_LOGS = 20
LogManager.logs = {}
LogManager.consoleEnabled = false
LogManager.debugInfo = {}

--- @param message string
function LogManager.Log(message)
    colorPrint(LogLevels.LOG, string.format("[LOG]: %s", message))
    table.insert(LogManager.logs, tostring(message))
    if #LogManager.logs > MAX_LOGS then
        table.remove(LogManager.logs, 1)
    end
end

--- @param message string
function LogManager.LogWarning(message)
    colorPrint(LogLevels.WARN, string.format("[LOGWarn]: %s", message))
    table.insert(LogManager.logs, "[Warning] " .. tostring(message))
    if #LogManager.logs > MAX_LOGS then
        table.remove(LogManager.logs, 1)
    end
end

--- @param message string
function LogManager.LogError(message)
    colorPrint(LogLevels.ERROR, string.format("[LOGError]: %s", message))
    table.insert(LogManager.logs, "[Error] " .. tostring(message))
    if #LogManager.logs > MAX_LOGS then
        table.remove(LogManager.logs, 1)
    end
end

--- @param message string
function LogManager.LogSuccess(message)
    colorPrint(LogLevels.SUCCESS, string.format("[LOGSuccess]: %s", message))
end

function LogManager.AddDebugInfo(key, value)
    LogManager.debugInfo[key] = value
end

function LogManager.ToggleConsole()
    LogManager.consoleEnabled = not LogManager.consoleEnabled
end

function LogManager.DrawConsole()
    if not LogManager.consoleEnabled then return end
    local x, y = 10, 10
    local lineHeight = 16
    local i = 0

    -- デバッグ情報
    for k, v in pairs(LogManager.debugInfo) do
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.print(string.format("%s: %s", k, v), x, y + i * lineHeight)
        i = i + 1
    end

    -- ログ履歴
    love.graphics.setColor(1, 1, 1, 1)
    for j = math.max(1, #LogManager.logs - 10), #LogManager.logs do
        love.graphics.print(LogManager.logs[j], x, y + i * lineHeight)
        i = i + 1
    end
end

return LogManager