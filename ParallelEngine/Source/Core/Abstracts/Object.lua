--- @class Object
local Object = {}
Object.__index = Object
Object.__name = "Object"


-- === construct method ===
-- = new method =

--- @private
function Object.New()
end

--- @protected
function Object:Init()
end

--- @return Object
function Object:Extend()
    --- @class Object
    local cls = {}

    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end

    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)

    return cls
end

--- @param T table
--- @return boolean
function Object:Is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

--- @return table
function Object:Dump()
    return {}
end

-- === metamethod ===

--- @private
function Object:__tostring()
    return "'Object'"
end



return Object