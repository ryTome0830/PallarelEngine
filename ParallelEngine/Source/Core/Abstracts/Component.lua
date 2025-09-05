--- @class Object
local Object = require("Abstracts.Object")

--- @class Component:Object
local Component = Object:Extend()
Component.__index = Component
Component.__name = "Component"


-- === construct method ===
-- = new method =


-- = override method =

--- @param ... table
function Component.New(...)
end

--- @protected
function Component:Init()
    self.super:Init()
    self._enabled = true
end

-- function Component:Extend() end
-- function Component:Is(T) end



-- === engine method === 
-- = new method =


-- = override method =

function Component:Awake() end
function Component:Start() end
function Component:Update(dt) end
function Component:Destroy() self:OnDestroy() end
function Component:IsEnabled() return self._enabled end


-- === callback ===
-- = new method =


-- = override method =

--- @private
function Component:OnInit() end
--- @private
function Component:OnEnable() end
--- @private
function Component:OnDisable() end
--- @private
function Component:OnDestroy() end


-- === metamethod ===

--- @protected
function Component:__tostring()
    return ""
end

--- @private
function Component:__newindex(key, value)
    if key == "_enabled" then
        if not TypeOf(key, "boolean") then
            error("Componentの'_enabled'型が異なります")
            return
        end
    end
    rawset(self, key, value)
end

return Component