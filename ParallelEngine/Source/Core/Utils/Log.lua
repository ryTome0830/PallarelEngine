--- @class LogManager
local LogManager = {}
LogManager.__index = LogManager
LogManager.__name = "LogManager"

LogManager.levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

--- @param message string
function LogManager:Log(message)
    
    print("[LOG] " .. message)
end

--- @param message string
function LogManager:LogWarning(message)
end

--- @param message string
function LogManager:Error(message)
end