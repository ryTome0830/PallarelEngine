--- @class Component
local Component = require("Core.Abstracts.Component")

--- @class UIElement: Component
--- @field x number
--- @field y number
--- @field w number
--- @field h number
--- @field visible boolean
--- @field enabled boolean
--- @field _enabled boolean
--- @field z number
--- @field hovered boolean
--- @field pressed boolean
--- @field children UIElement[]
--- @field parent UIElement|table

--- @class UIElement
local UIElement = Component:Extend()
UIElement.__index = UIElement
UIElement.__name = "UIElement"


--- @alias UIETypes
--- | "Button"
--- | "Text"
--- | "Image"

--- @enum UIElementTypes
local UIElementTypes = {
    Button = "Button",
    Text = "Text",
    Image = "Image",
}



--- @param parent? table
--- @param props? table
--- @return UIElement
function UIElement.New(parent, props)
    -- support calling New(props)
    if props == nil and type(parent) == "table" and not parent.__name then
        props = parent
        parent = nil
    end
    props = props or {}

    --- @class UIElement
    local instance = setmetatable({}, UIElement)
    instance:Init(props)
    -- set parent reference (manager will call AddChild to attach)
    instance.parent = nil
    instance.hovered = false
    instance.pressed = false
    instance.children = {}
    return instance
end


--- @param self UIElement
function UIElement:Init(props)
    props = props or {}
    self.super:Init()

    self.x = props.x or 0
    self.y = props.y or 0
    self.w = props.w or (props.width or 100)
    self.h = props.h or (props.height or 30)
    self.visible = props.visible ~= false

    if props.enabled ~= nil then
        self._enabled = props.enabled
    end

    if self._enabled == nil then
        self._enabled = true
    end
    self.enabled = self._enabled
    self.z = props.z or 0
end

--- @param self UIElement
function UIElement:ContainsPoint(px, py)
    return px >= self.x and px <= (self.x + self.w) and py >= self.y and py <= (self.y + self.h)
end

--- @param self UIElement
function UIElement:Draw()
    for _, child in ipairs(self.children) do
        if child.visible then
            child:Draw()
        end
    end
end

--- @param self UIElement
function UIElement:Update(dt)
    for _, child in ipairs(self.children) do
        if child.enabled then
            child:Update(dt)
        end
    end
end

--- @param self UIElement
function UIElement:OnMousePressed(x, y, button)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.visible and child.enabled and child:ContainsPoint(x, y) then
            if child:OnMousePressed(x, y, button) then
                return true
            end
        end
    end
    return false
end

--- @param self UIElement
function UIElement:OnMouseReleased(x, y, button)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child.visible and child.enabled then
            if child:OnMouseReleased(x, y, button) then
                return true
            end
        end
    end
    return false
end

--- @param self UIElement
function UIElement:OnMouseMoved(x, y, dx, dy)
    self.hovered = self:ContainsPoint(x, y)
    for _, child in ipairs(self.children) do
        if child.visible and child.enabled then
            child:OnMouseMoved(x, y, dx, dy)
        end
    end
end

--- @param self UIElement
function UIElement:AddChild(child)
    child.parent = self
    table.insert(self.children, child)
end

--- @param self UIElement
function UIElement:SetActive(state)
    if type(state) ~= "boolean" or self._enabled == state then
        return
    end
    self._enabled = state
    self.enabled = state
    if self._enabled then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

return UIElement
