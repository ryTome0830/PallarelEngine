--- @class UIElement
local UIElement = require("Core.UI.UIElement")

--- @class Image:UIElement
local Image = UIElement:Extend()
Image.__index = Image
Image.__name = "Image"

--- @param parent? table
--- @param props? table
function Image.New(parent, props)
    if props == nil and type(parent) == "table" and not parent.__name then
        props = parent
        parent = nil
    end
    props = props or {}

    --- @class UIElement
    local instance = UIElement.New(parent, props)
    setmetatable(instance, Image)
    instance.image = props.image
    instance.scale = props.scale or 1
    return instance
end

function Image:Draw()
    if not self.visible or not self.image then return end
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale)
    UIElement.Draw(self)
end

return Image
