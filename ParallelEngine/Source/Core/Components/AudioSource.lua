--- @class Component
local Component = require("Core.Abstracts.Component")
local Component = require("Core.Abstracts.Component")
local LogManager = require("Core.LogManager")

--- @class AudioSource:Component
local AudioSource = Component:Extend()
AudioSource.__index = AudioSource
AudioSource.__name = "AudioSource"
AudioSource.Serializable = {"_enabled", "audioClip", "loop", "volume"}

--- @class AudioSourceProperties
--- @field _enabled? boolean
--- @field audioClip? string
--- @field loop? boolean
--- @field volume? number


function AudioSource.New(gameObject, properties)
    local instance = setmetatable({}, AudioSource)
    instance:Init(gameObject, properties)
    return instance
end

function AudioSource:Init(gameObject, properties)
    self.super:Init()
    properties = properties or {}

    self.gameObject = gameObject
    self._source = nil

    self.audioClip = properties.audioClip or nil
    self.loop = properties.loop or false
    self.volume = properties.volume or 1.0
    self._enabled = properties._enabled ~= false

    if self.audioClip then
        local ok, src = pcall(love.audio.newSource, self.audioClip, "static")
        if ok and src then
            self._source = src
            self._source:setLooping(self.loop)
            self._source:setVolume(self.volume)
        else
            LogManager.LogError("AudioSource: failed to load audioClip: " .. tostring(self.audioClip))
            self._source = nil
        end
    end
end

function AudioSource:Awake()
    if not self._source and self.audioClip then
        local ok, src = pcall(love.audio.newSource, self.audioClip, "static")
        if ok and src then
            self._source = src
            self._source:setLooping(self.loop)
            self._source:setVolume(self.volume)
        end
    end
end

function AudioSource:Start()
end

function AudioSource:Play()
    if not self:IsEnabled() then return end
    if not self._source and self.audioClip then
        local ok, src = pcall(love.audio.newSource, self.audioClip, "static")
        if ok and src then
            self._source = src
        end
    end
    if self._source then
        self._source:setLooping(self.loop)
        self._source:setVolume(self.volume)
        pcall(function() self._source:play() end)
    end
end

function AudioSource:Stop()
    if self._source then
        pcall(function() self._source:stop() end)
    end
end

function AudioSource:SetVolume(v)
    self.volume = v or 1.0
    if self._source then
        self._source:setVolume(self.volume)
    end
end

function AudioSource:IsPlaying()
    if not self._source then return false end
    local ok, val = pcall(function() return self._source:isPlaying() end)
    if not ok then return false end
    return val
end

function AudioSource:Destroy()
    if self._source then
        pcall(function()
            if self._source.stop then self._source:stop() end
        end)
        self._source = nil
    end
    self.gameObject = nil
end

return AudioSource
