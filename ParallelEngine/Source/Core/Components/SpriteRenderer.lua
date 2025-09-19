--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class Transform
local Transform = require("Core.Transform")
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
local ImageCache = {}

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

    self.gameObject = gameObject
    self.texturePath = properties.texturePath or nil
    self.color = properties.color or {1,1,1,1}
    self.origin = properties.origin or {x=0, y=0}

    if properties._enabled == nil then
        self._enabled = true
    else
        self._enabled = properties._enabled
    end

    self.crop = properties.crop
    self.size = properties.size or {w=self.gameObject.transform.scale.x, h=self.gameObject.transform.scale.y}

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
end


function SpriteRenderer:Draw()
    if not self:IsEnabled() then return end
    if not self.gameObject or not self.gameObject.transform then return end

    local t = self.gameObject.transform
    love.graphics.setColor(self.color)

    if not self.image then
        local w = self.size and self.size.w or t.scale.x
        local h = self.size and self.size.h or t.scale.y
        local ox = self.origin and self.origin.x or 0
        local oy = self.origin and self.origin.y or 0

        love.graphics.push()
        love.graphics.translate(t.position.x, t.position.y)
        love.graphics.rotate(t.rotation)
        love.graphics.rectangle("fill", -w/2, -h/2, w, h)
        love.graphics.pop()
    else
        local scaleX, scaleY = t.scale.x, t.scale.y
        if self.size and self.crop then
            scaleX = self.size.w / self.crop.w
            scaleY = self.size.h / self.crop.h
        elseif self.size then
            scaleX = self.size.w / self.image:getWidth()
            scaleY = self.size.h / self.image:getHeight()
        end
        local rotationRad = t.rotation
        if self.quad then
            love.graphics.draw(self.image, self.quad, t.position.x, t.position.y, rotationRad, scaleX, scaleY, self.origin.x, self.origin.y)
        else
            love.graphics.draw(self.image, t.position.x, t.position.y, rotationRad, scaleX, scaleY, self.origin.x, self.origin.y)
        end
    end

    love.graphics.setColor(1,1,1,1)
end


return SpriteRenderer
