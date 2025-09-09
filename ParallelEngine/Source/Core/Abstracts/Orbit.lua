--- @class Object
local Object = require("Core.Abstracts.Object")

--- @class Orbit:Object
local Orbit = Object:Extend()
Orbit.__index = Orbit
Orbit.__name = "Orbit"


-- === construct method ===

--- @private
function Orbit.New()
end

--- @protected
function Orbit:Init()
    self.super:Init()

    self._enabled = true
    self._awaked = false
    self._started = false
    self._isDestroyed = false
end

--- @return Orbit
function Orbit:Extend()
    --- @class Orbit
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

function Orbit:Clone()
end

-- === engine method ===
-- = new method =

function Orbit:Awake()
end

function Orbit:Start()
end

--- @param dt number
function Orbit:Update(dt)
end

function Orbit:Draw()
end

function Orbit:Destroy()
end

--- @return boolean
function Orbit:IsEnabled()
    return self._enabled
end

--- @param state boolean
function Orbit:SetActive(state)
    if type(state) ~= "boolean" or self._enabled == state then
        return
    end

    self._enabled = state

    if self._enabled then
       self:OnEnable()
    else
        self:OnDisable()
    end
end



-- === callback ===
-- = new method =

--- @protected
function Orbit:OnInit()
end

--- @protected
function Orbit:OnEnable()
end

--- @protected
function Orbit:OnDisable()
end

--- @protected
function Orbit:OnDestroy()
    self._enabled = false
    self._isDestroyed = true
end



--- === metamethod ===

--- @private
function Orbit:__tostring()
    return "'Orbit' enabled: " .. tostring(self._enabled)
end



return Orbit