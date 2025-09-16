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

--- @param message string
function LogManager.Log(message)
    colorPrint(LogLevels.LOG, string.format("[LOG]: %s", message))
end

--- @param message string
function LogManager.LogWarning(message)
    colorPrint(LogLevels.WARN, string.format("[LOGWarn]: %s", message))
end

--- @param message string
function LogManager.LogError(message)
    colorPrint(LogLevels.ERROR, string.format("[LOGError]: %s", message))
end

--- @param message string
function LogManager.LogSuccess(message)
    colorPrint(LogLevels.SUCCESS, string.format("[LOGSuccess]: %s", message))
end

return LogManager