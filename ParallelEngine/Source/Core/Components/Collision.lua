--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class RigidBody
local RigidBody = require("Core.Components.RigidBody")
--- @class Physics
local Physics = require("Core.Physics")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class Collision:Component
local Collision = Component:Extend()
Collision.__index = Collision
Collision.__name = "Collision"

Collision.Serializable = {"_enabled", "size", "offset", "isSensor"}

local PPM = Physics.PPM

--- @param gameObject GameObject
--- @param properties CollisionPropertiesDefinition
function Collision.New(gameObject, properties)
    local instance = setmetatable({}, Collision)
    instance:Init(gameObject, properties)
    return instance
end

--- @param gameObject GameObject
--- @param properties CollisionPropertiesDefinition
function Collision:Init(gameObject, properties)
    self.super:Init()
    properties = properties or {}

    self.gameObject = gameObject
    self.size = properties.size or {x=self.gameObject.transform.scale.x, y=self.gameObject.transform.scale.y} or {x=32, y=32}
    self.offset = properties.offset or {x=0, y=0}

    if properties.isSensor == nil then
        self.isSensor = false
    else
        self.isSensor = properties.isSensor
    end

    if properties._enabled == nil then
        self._enabled = true
    else
        self._enabled = properties._enabled
    end

    self.fixture = nil
    self.shape = nil
end

function Collision:Start()
    if self.fixture then return end

    --- @type RigidBody|nil
    local rb = self.gameObject and self.gameObject:GetComponent(RigidBody)

    if not rb then
        LogManager.LogError("Collision component requires a RigidBody component on '" .. self.gameObject.name .. "'.")
        return
    end

    if not rb.body then
        LogManager.LogError("Failed to create fixture: RigidBody's physics body is not available. Check initialization order.")
        return
    end

    print(string.format("[Collision] '%s' の当たり判定サイズ（ピクセル）: x=%.2f, y=%.2f", self.gameObject.name, self.size.x, self.size.y))

    local width_m = (self.size.x or 32) / PPM
    local height_m = (self.size.y or 32) / PPM
    local offsetX_m = (self.offset.x or 0) / PPM
    local offsetY_m = (self.offset.y or 0) / PPM

    if width_m <= 0 or height_m <= 0 then
        LogManager.LogError(string.format(
            "Invalid collision shape size for '%s'. Width and height must be positive. Got size: (%f, %f)",
            self.gameObject.name, self.size.x, self.size.y
        ))
        return
    end

    print(string.format("[Collision] '%s' が物理エンジンに渡すサイズ（メートル）: w=%.4f, h=%.4f", self.gameObject.name, width_m, height_m))
    self.shape = love.physics.newRectangleShape(offsetX_m, offsetY_m, width_m, height_m)


    self.fixture = love.physics.newFixture(rb.body, self.shape)
    self.fixture:setSensor(self.isSensor)
    self.fixture:setUserData(self)

    if rb.shapes then
        table.insert(rb.shapes, self.fixture)
    end
end

function Collision:OnCollisionEnter(other)
    -- otherは衝突した相手のCollisionインスタンス
    print(self.gameObject.name .. " が " .. (other.gameObject and other.gameObject.name or "不明") .. " と衝突しました")
    -- ここに衝突時の処理を書く（例：ダメージ、反射、サウンド再生など）
end

function Collision:OnCollisionExit(other)
end

function Collision:Destroy()
    if self.fixture then
        pcall(function() self.fixture:destroy() end)
    end
    self.fixture = nil
    self.shape = nil
end

function Collision:Dump()
    return Component.Dump(self)
end


return Collision