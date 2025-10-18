--- @class Component
local Component = require("Core.Component")

--- @class Animation:Component
local Animation = Component:Extend()
Animation.__index = Animation
Animation.__name = "Animation"
Animation.Serializable = {"_enabled", "animationData"}

--- @class AnimationProperties
--- @field _enabled? boolean
--- @field animationData? AnimationData[]

--- @class AnimationData
--- @field name string
--- @field frames AnimationFrame

--- @class AnimationFrame
local AnimationFrame

--- @param gameObject GameObject
--- @param properties AnimationProperties
--- @return Animation
function Animation.New(gameObject, properties)
    --- @class Animation
    local instance = setmetatable({}, Animation)
    instance:Init(gameObject, properties)
    return instance
end


--- @param gameObject GameObject
--- @param properties AnimationProperties
function Animation:Init(gameObject, properties)
    self.super:Init()
    self.gameObject = gameObject
    self._enabled = properties._enabled
    self._animationData = properties.animationData

    self._currentAnimationData = nil
    self._currentTime = 0
    self._isPlaying = false
    self._isLoop = false
end

function Animation:Awake()
end

function Animation:Start()
end

function Animation:Update(dt)
    
end

--- @param name string
--- @param loop boolean
function Animation:Play(name, loop)
    self._currentAnimationData = FindInTable(self._animationData, function(data) return data.name == name end)

    self._isPlaying = true
    self._isLoop = loop or false
    self:ApplyCurrentFrame()
end

function Animation:Stop()
    self._currentTime = 0
    self._isPlaying = false
    self._isLoop = false
end

function Animation:ApplyCurrentFrame()
    
end

function Animation:Pause()
    
end