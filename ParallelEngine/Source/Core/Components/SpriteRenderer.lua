local Component = require("Core.Abstracts.Component")
local Transform = require("Core.Transform")

--- @class SpriteRenderer:Component
local SpriteRenderer = Component:Extend()
SpriteRenderer.__index = SpriteRenderer
SpriteRenderer.__name = "SpriteRenderer"

SpriteRenderer.Serializable = {"_enabled", "texturePath", "color", "origin", "crop", "size"}

function SpriteRenderer.New(properties)
    local instance = setmetatable({}, SpriteRenderer)
    instance:Init(properties)
    return instance
end

function SpriteRenderer:Init(properties)
    self.super:Init()
    properties = properties or {}

    self.texturePath = properties.texturePath or nil
    self.color = properties.color or {1,1,1,1}
    self.origin = properties.origin or {x=0, y=0}
    self._enabled = properties._enabled
    self.crop = properties.crop -- {x, y, w, h}
    self.size = properties.size -- {w, h}

    self.image = nil
    self.quad = nil
    if self.texturePath then
        local ok, img = pcall(love.graphics.newImage, self.texturePath)
        if ok then
            self.image = img
            if self.crop then
                self.quad = love.graphics.newQuad(
                    self.crop.x, self.crop.y, self.crop.w, self.crop.h,
                    img:getWidth(), img:getHeight()
                )
            end
        end
    end
end

function SpriteRenderer:Draw()
    if not self:IsEnabled() then return end
    if not self.image then return end
    if not self.gameObject or not self.gameObject.transform then return end

    local t = self.gameObject.transform
    love.graphics.setColor(self.color)

    local scaleX, scaleY = t.scale.x, t.scale.y
    if self.size and self.crop then
        scaleX = self.size.w / self.crop.w
        scaleY = self.size.h / self.crop.h
    elseif self.size then
        scaleX = self.size.w / self.image:getWidth()
        scaleY = self.size.h / self.image:getHeight()
    end

    if self.quad then
        love.graphics.draw(self.image, self.quad, t.position.x, t.position.y, t.rotation, scaleX, scaleY, self.origin.x, self.origin.y)
    else
        love.graphics.draw(self.image, t.position.x, t.position.y, t.rotation, scaleX, scaleY, self.origin.x, self.origin.y)
    end

    love.graphics.setColor(1,1,1,1)
end

function SpriteRenderer:Dump()
    return Component.Dump(self)
end

return SpriteRenderer
