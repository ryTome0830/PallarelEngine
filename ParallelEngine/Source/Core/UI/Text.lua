--- @class UIElement
local UIElement = require("Core.UI.UIElement")

--- @class Text:UIElement
local Text = UIElement:Extend()
Text.__index = Text
Text.__name = "Text"

--- @param parent? table
--- @param props? table
function Text.New(parent, props)
    if props == nil and type(parent) == "table" and not parent.__name then
        props = parent
        parent = nil
    end
    props = props or {}

    local instance = UIElement.New(parent, props)
    setmetatable(instance, Text)
    instance.text = props.text or ""
    instance.font = props.font or love.graphics.newFont(12)
    instance.color = props.color or {1,1,1,1}
    return instance
end

function Text:Draw()
    if not self.visible then return end
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    love.graphics.print(self.text, self.x, self.y)
    love.graphics.setColor(1,1,1,1)
    UIElement.Draw(self)
end

return Text
