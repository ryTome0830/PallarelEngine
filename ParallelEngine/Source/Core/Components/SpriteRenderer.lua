--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class Transform
local Transform = require("Core.Transform")
--- @class Collision
local Collision = require("Core.Components.Collision")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class SpriteRendererProperties
--- @field _enabled? boolean
--- @field texturePath? string
--- @field color? {r: number, g: number, b: number, a:number} 0 to 1
--- @field origin? {x: number, y: number} 
--- @field crop? {x: number, y: number, w: number, h: number}
--- @field size? {w: number, h: number}

--- @class SpriteRenderer:Component
local SpriteRenderer = Component:Extend()
SpriteRenderer.__index = SpriteRenderer
SpriteRenderer.__name = "SpriteRenderer"

SpriteRenderer.Serializable = {"_enabled", "texturePath", "color", "origin", "crop", "size"}

-- 画像キャッシュテーブル
--- @type table<string, love.Image>
local ImageCache = {}
local VISUAL_PADDING = 4

--- @param gameObject GameObject
--- @param properties SpriteRendererProperties
function SpriteRenderer.New(gameObject, properties)
    local instance = setmetatable({}, SpriteRenderer)
    instance:Init(gameObject, properties)
    return instance
end

--- @param gameObject GameObject
--- @param properties SpriteRendererProperties
function SpriteRenderer:Init(gameObject, properties)
    self.super:Init()
    properties = properties or {}

    -- UnSerializable
    self.gameObject = gameObject
    --- @private
    --- @type {w: number, h: number}
    self.drawSize = {w = 0, h = 0}
    --- @private
    --- @type {w: number, h:number}
    self.drawScale = {w = 1, h = 1}

    -- Serializable
    self.texturePath = properties.texturePath or nil
    self.color = properties.color or {1,1,1,1}
    self.origin = properties.origin or {x=0, y=0}
    self._enabled = properties._enabled ~= false
    self.crop = properties.crop

    self.image = nil
    self.quad = nil
    if self.texturePath then
        if ImageCache[self.texturePath] then
            self.image = ImageCache[self.texturePath]
        else
            local ok, img = pcall(love.graphics.newImage, self.texturePath)
            if ok then
                self.image = img
                ImageCache[self.texturePath] = img
            else
                LogManager.LogError("texturePath is not available")
            end
        end
        if self.image then
            if not properties.origin then
                self.origin = {x = self.image:getWidth() / 2, y = self.image:getHeight() / 2}
            end

            if self.crop then
                self.quad = love.graphics.newQuad(
                    self.crop.x, self.crop.y, self.crop.w, self.crop.h,
                    self.image:getWidth(), self.image:getHeight()
                )
                if not properties.origin then
                    self.origin = {x = self.crop.w / 2, y = self.crop.h / 2}
                end
            end
        else
            LogManager.LogError("texturePath is not available")
        end
    end

    self:Resize()
end

function SpriteRenderer:Start()
    if self.gameObject then
        local t = self.gameObject.transform
        t.onScaleChanged:Subscribe(function(newScale)
            self:Resize()
        end)
    end
end

function SpriteRenderer:Draw()
    if not self:IsEnabled() then return end
    if not self.gameObject or not self.gameObject.transform then return end

    local t = self.gameObject.transform
    love.graphics.setColor(self.color)

    if not self.image then
        love.graphics.push()
        love.graphics.translate(t.position.x, t.position.y)
        love.graphics.rotate(t.rotation)
        love.graphics.rectangle(
            "fill",
            -self.drawSize.w/2,
            -self.drawSize.h/2,
            self.drawSize.w,
            self.drawSize.h
        )
        love.graphics.pop()
    else
        local rotationRad = t.rotation
        if self.quad then
            love.graphics.draw(self.image, self.quad, t.position.x, t.position.y, rotationRad, self.drawScale.w, self.drawScale.h, self.origin.x, self.origin.y)
        else
            love.graphics.draw(self.image, t.position.x, t.position.y, rotationRad, self.drawScale.w, self.drawScale.h, self.origin.x, self.origin.y)
        end
    end

    love.graphics.setColor(1,1,1,1)
end

--- @private
function SpriteRenderer:Resize()
    local scale = self.gameObject.transform.scale
    local finalSize = {w=scale.x, h=scale.y}

    local collisionComp = self.gameObject:GetComponent(Collision)
    if collisionComp then
        finalSize.w = finalSize.w + VISUAL_PADDING
        finalSize.h = finalSize.h + VISUAL_PADDING
    end

    self.drawSize = finalSize
    if self.image then
        if self.crop then
            self.drawScale.w = finalSize.w / self.crop.w
            self.drawScale.h = finalSize.h / self.crop.h
        else
            self.drawScale.w = finalSize.w / self.image:getWidth()
            self.drawScale.h = finalSize.h / self.image:getHeight()
        end
    end
end

return SpriteRenderer
