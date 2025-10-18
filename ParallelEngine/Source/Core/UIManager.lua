--- @class UIElement
local UIElement = require("Core.UI.UIElement")
--- @class TypeRegistry
local TypeRegistry = require("Core.TypeRegistry")
--- @class LogManager
local LogManager = require("Core.LogManager")


--- @class UIManager
--- @field root UIElement
--- @field elements UIElement[]
--- @field components table[]
--- @field canvases table<string, table>
local UIManager = {}
UIManager.__index = UIManager
UIManager.__name = "UIManager"

local SingletonInstance

--- @return UIManager
function UIManager.New()
    if not SingletonInstance then
        local instance = setmetatable({}, UIManager)
        instance.root = UIElement.New({x=0, y=0, w=0, h=0})
        --- @type UIElement[]
        instance.elements = {}
        --- @type table[]
        instance.components = {}
    --- @type table<string, table>
    instance.canvases = {}
        SingletonInstance = instance
    end
    return SingletonInstance
end

--- @param name string
--- @param opts table
function UIManager:NewCanvas(name, opts)
    if not name then return nil end
    if self.canvases[name] then return self.canvases[name] end
    local UICanvas = require("Core.UI.UICanvas")
    local canvas = UICanvas.New(name, opts)
    self.canvases[name] = canvas
    return canvas
end

function UIManager:GetCanvas(name)
    return self.canvases[name]
end


--- @param element table|UIElement
function UIManager:Add(element)
    if not element then
        LogManager.LogError("UIManager:Add - element is nil")
        return nil
    end

    if type(element) == "table" and (type(element.elementType) == "string") then
        local typeName = element.elementType or "text"
        local cls = TypeRegistry.Get(typeName)
        if not cls then
            LogManager.LogError("UIManager:Add - class not found: " .. typeName)
            return nil
        end

        if type(cls.New) ~= "function" then
            LogManager.LogError("UIManager:Add - resolved class has no New method: " .. typeName)
            return nil
        end

        local clsNew = cls.New
        local ok, inst = pcall(clsNew, cls, element.properties or {})
        if not ok or not TypeOf(inst, UIElement) then
            ok, inst = pcall(clsNew, element.properties or {})
        end
        if not ok or not TypeOf(inst, UIElement) then
            LogManager.LogError("UIManager:Add - created instance is not a UIElement: " .. tostring(typeName))
            return nil
        end
        table.insert(self.elements, inst)
        self.root:AddChild(inst)
        return inst
    end

    if TypeOf(element, UIElement) then
        table.insert(self.elements, element)
        self.root:AddChild(element)
        return element
    end
    return nil
end

--- @param componentClass table|string
--- @param properties table
function UIManager:AddComponent(componentClass, properties)
    if type(componentClass) == "string" then
        local resolved = TypeRegistry.Get(componentClass)
        if not resolved then
            LogManager.LogError("UIManager:AddComponent - class not found: " .. tostring(componentClass))
            return nil
        end
        componentClass = resolved
    end

    if type(componentClass) ~= "table" or type(componentClass.New) ~= "function" then
        LogManager.LogError("UIManager:AddComponent - invalid component class")
        return nil
    end

    local comp = nil
    local ok, inst = pcall(componentClass.New, componentClass, properties)
    if ok and inst then
        comp = inst
    else
        ok, inst = pcall(componentClass.New, componentClass, self, properties)
        if ok and inst then
            comp = inst
        end
    end
    if not comp then
        LogManager.LogError("UIManager:AddComponent - failed to instantiate component")
        return nil
    end
    table.insert(self.components, comp)
    return comp
end

--- @param componentClass table|string
function UIManager:GetComponent(componentClass)
    local cls = componentClass
    if type(componentClass) == "string" then
        --- @type table|nil
        local resolved = TypeRegistry.Get(componentClass)
        if not resolved then return nil end
        cls = resolved
    end
    for _, c in ipairs(self.components) do
        if TypeOf(c, cls) then
            return c
        end
    end
    return nil
end

function UIManager:RemoveComponent(componentOrClass)
    local cls = componentOrClass
    if type(componentOrClass) == "string" then
        --- @type table|nil
        local resolved = TypeRegistry.Get(componentOrClass)
        cls = resolved
    end
    for i = #self.components, 1, -1 do
        local c = self.components[i]
        if componentOrClass == c or (cls and TypeOf(c, cls)) then
            if type(c.Destroy) == "function" then
                c:Destroy()
            end
            table.remove(self.components, i)
            return true
        end
    end
    return false
end

function UIManager:Update(dt)
    if not TypeOf(dt, "number") then
        LogManager.LogError("UIManager:Update - dt must be a number")
        return
    end

    for _, c in ipairs(self.components) do
        if type(c.Update) == "function" then
            c:Update(dt)
        end
    end
    self.root:Update(dt)
end

function UIManager:Draw()
    for _, c in ipairs(self.components) do
        if type(c.Draw) == "function" then
            c:Draw()
        end
    end
    self.root:Draw()
end

function UIManager:OnMousePressed(x, y, button)
    return self.root:OnMousePressed(x, y, button)
end

function UIManager:OnMouseReleased(x, y, button)
    return self.root:OnMouseReleased(x, y, button)
end

function UIManager:OnMouseMoved(x, y, dx, dy)
    return self.root:OnMouseMoved(x, y, dx, dy)
end

return UIManager
