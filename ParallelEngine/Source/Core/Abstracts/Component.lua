--- @class Orbit
local Orbit = require("Core.Abstracts.Orbit")

--- @class Component:Orbit
local Component = Orbit:Extend()
Component.__index = Component
Component.__name = "Component"

Component.Serializable = {"_enabled"}

-- === construct method ===

--- @param properties table
function Component.New(properties)
end

--- @param properties table
--- @protected
function Component:Init(properties)
    self.super:Init()
end

--- @return table
function Component:Clone()
    return self:Dump()
end

--- @return table
function Component:Dump()
    local properties = {}
    local propertyList = getmetatable(self).Serializable

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