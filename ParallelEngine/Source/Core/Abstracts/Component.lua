--- @class Orbit
local Orbit = require("Core.Abstracts.Orbit")

--- @class Component:Orbit
--- @field gameObject GameObject
--- @field _enabled boolean
local Component = Orbit:Extend()
Component.__index = Component
Component.__name = "Component"

Component.Serializable = {"_enabled"}

-- === construct method ===

--- @param gameObject GameObject
--- @param properties table
function Component.New(gameObject, properties)
end

--- @param properties table
--- @protected
function Component:Init(properties)
    self.super:Init()
end

--- @generic T:Component
--- @return table
function Component:Clone()
    local properties = {}
    local cls = self.__index
    local propertyList = cls.Serializable

    for _, key in ipairs(propertyList) do
        if self[key] ~= nil then
            properties[key] = self[key]
        end
    end

    return properties
end

--- @return table
function Component:Dump()
    local properties = {}
    local propertyList = self.__index.Serializable

    if propertyList then
        for _, key in ipairs(propertyList) do
            if self[key] ~= nil then
                properties[key] = self[key]
            end
        end
    end
    return properties
end

-- === engine method === 



-- === callback ===



-- === metamethod ===

--- @protected
function Component:__tostring()
    return "'Component': " .. self._enabled
end



return Component