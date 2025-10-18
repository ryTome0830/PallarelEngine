--- @class UIElement
local UIElement = require("Core.UI.UIElement")

--- @class Label:UIElement
local Label = UIElement:Extend()
Label.__index = Label
Label.__name = "Label"
Label.__serializable = {"text", "font", "color"}

function Label.New(parent, props)
    -- support calling New(props)
    if props == nil and type(parent) == "table" and not parent.__name then
        props = parent
        parent = nil
    end
    props = props or {}
    --- @class UIElement
    local instance = UIElement.New(parent, props)
    setmetatable(instance, Label)
    instance.text = props.text or "Label"
    instance.font = props.font or love.graphics.newFont(12)
    instance.color = props.color or {1,1,1,1}
    return instance
end

function Label:Draw()
    if not self.visible then return end
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    love.graphics.print(self.text, self.x, self.y)
    love.graphics.setColor(1,1,1,1)
    UIElement.Draw(self)
end

return Label
