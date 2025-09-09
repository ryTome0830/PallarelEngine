--- @class Orbit
local Orbit = require("Core.Abstracts.Orbit")

--- @class Component:Orbit
local Component = Orbit:Extend()
Component.__index = Component
Component.__name = "Component"


-- === construct method ===

--- @param ... table
function Component.New(...)
end

--- @protected
function Component:Init()
    self.super:Init()
end

--- @return Component|nil
function Component:Clone()
end

-- === engine method === 



-- === callback ===



-- === metamethod ===

--- @protected
function Component:__tostring()
    return "'Component': " .. self._enabled
end



return Component