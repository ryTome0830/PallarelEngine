--- @class UIElement
local UIElement = require("Core.UI.UIElement")
--- @class Label
local Label = require("Core.UI.Label")

--- @class Button:UIElement
local Button = UIElement:Extend()
Button.__index = Button
Button.__name = "Button"

--- @param parent? table
--- @param props? table
function Button.New(parent, props)
    if props == nil and type(parent) == "table" and not parent.__name then
        props = parent
        parent = nil
    end
    props = props or {}

    --- @class UIElement
    local instance = UIElement.New(parent, props)
    setmetatable(instance, Button)
    instance.text = props.text or "Button"
    instance.onClick = props.onClick
    instance.bgColor = props.bgColor or {0.2,0.6,1,1}
    instance.hoverColor = props.hoverColor or {0.3,0.7,1,1}
    instance.label = Label.New({x = instance.x + 6, y = instance.y + 6, text = instance.text, font = props.font})
    instance:AddChild(instance.label)
    return instance
end

function Button:Draw()
    if not self.visible then return end
    local color = self.hovered and self.hoverColor or self.bgColor
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1,1,1,1)
    UIElement.Draw(self)
end

function Button:OnMousePressed(x, y, button)
    if button ~= 1 then return false end
    if self:ContainsPoint(x, y) then
        self.pressed = true
        return true
    end
    return UIElement.OnMousePressed(self, x, y, button)
end

function Button:OnMouseReleased(x, y, button)
    if button ~= 1 then return false end
    if self.pressed then
        self.pressed = false
        if self:ContainsPoint(x, y) then
            if self.onClick then self.onClick(self) end
            -- sync label text after click
            if self.label then
                self.label.text = tostring(self.text)
            end
            return true
        end
    end
    return UIElement.OnMouseReleased(self, x, y, button)
end

--- @param self Button
function Button:OnMouseMoved(x, y, dx, dy)
    UIElement.OnMouseMoved(self, x, y, dx, dy)
    if self.label then
        self.label.text = tostring(self.text)
        self.label.x = self.x + (self.w - (self.label.font and self.label.font:getWidth(self.label.text) or 0))/2
        self.label.y = self.y + (self.h - (self.label.font and self.label.font:getHeight() or 0))/2
    end
end

return Button
