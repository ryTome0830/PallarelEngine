local UIElement = require("Core.UI.UIElement")

local Panel = setmetatable({}, {__index = UIElement})
Panel.__index = Panel

function Panel.New(props)
    props = props or {}
    local instance = UIElement.New(props)
    setmetatable(instance, Panel)
    instance.bgColor = props.bgColor or nil
    return instance
end

function Panel:Draw()
    if not self.visible then return end
    if self.bgColor then
        love.graphics.setColor(self.bgColor)
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        love.graphics.setColor(1,1,1,1)
    end
    UIElement.Draw(self)
end

return Panel
