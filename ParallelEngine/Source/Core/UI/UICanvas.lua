local UIElement = require("Core.UI.UIElement")

local UICanvas = {}
UICanvas.__index = UICanvas
UICanvas.__name = "UICanvas"

--- Create a new canvas
--- @param name string
--- @param opts table { worldSpace = boolean, pivot = string }
function UICanvas.New(name, opts)
    opts = opts or {}
    --- @class UICanvas
    local instance = setmetatable({}, UICanvas)
    instance.name = name
    instance.worldSpace = opts.worldSpace or false
    instance.pivot = opts.pivot or "topleft" -- supported: 'topleft', 'center'
    instance.debugHits = opts.debugHits or false
    instance.gameObjects = {}
    instance.uiElements = {}
    -- compute origin
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    if instance.pivot == "center" then
        instance.originX = w / 2
        instance.originY = h / 2
    else
        instance.originX = 0
        instance.originY = 0
    end
    return instance
end

function UICanvas:AddGameObject(go)
    if not go then return end
    table.insert(self.gameObjects, go)
    -- Ensure any pending components (added just before attaching) are initialized
    if type(go.Update) == "function" then
        -- call with dt=0 to flush pendingComponents -> components via GameObject:Update
        pcall(function() go:Update(0) end)
    end
end

function UICanvas:RemoveGameObject(go)
    for i=#self.gameObjects,1,-1 do
        if self.gameObjects[i] == go then
            table.remove(self.gameObjects, i)
            return true
        end
    end
    return false
end

function UICanvas:Update(dt)
    for _, go in ipairs(self.gameObjects) do
        -- update UI components attached to the gameObject
        if go and go.components then
            for _, comp in ipairs(go.components) do
                if TypeOf(comp, UIElement) and comp:IsEnabled() then
                    comp:Update(dt)
                end
            end
        end
    end
    -- update direct UI elements
    for _, comp in ipairs(self.uiElements) do
        if TypeOf(comp, UIElement) and comp:IsEnabled() then
            comp:Update(dt)
        end
    end
end

function UICanvas:Draw()
    love.graphics.push()
    love.graphics.translate(self.originX, self.originY)
    for _, go in ipairs(self.gameObjects) do
        if go and go.components then
            for _, comp in ipairs(go.components) do
                if TypeOf(comp, UIElement) and comp.visible then
                    comp:Draw()
                    if self.debugHits then
                        love.graphics.setColor(1,0,0,1)
                        love.graphics.rectangle("line", comp.x, comp.y, comp.w, comp.h)
                        love.graphics.setColor(1,0.2,0.2,1)
                        love.graphics.rectangle("fill", comp.x - 2, comp.y - 2, 4, 4)
                        love.graphics.circle("fill", comp.x + comp.w/2, comp.y + comp.h/2, 3)
                        love.graphics.setColor(1,1,1,1)
                    end
                end
            end
        end
    end
    -- draw direct UI elements
    for _, comp in ipairs(self.uiElements) do
        if TypeOf(comp, UIElement) and comp.visible then
            comp:Draw()
            if self.debugHits then
                love.graphics.setColor(1,0,0,1)
                love.graphics.rectangle("line", comp.x, comp.y, comp.w, comp.h)
                love.graphics.setColor(1,0.2,0.2,1)
                love.graphics.rectangle("fill", comp.x - 2, comp.y - 2, 4, 4)
                love.graphics.circle("fill", comp.x + comp.w/2, comp.y + comp.h/2, 3)
                love.graphics.setColor(1,1,1,1)
            end
        end
    end
    love.graphics.pop()
end

function UICanvas:_localCoords(x, y)
    return x - self.originX, y - self.originY
end

function UICanvas:OnMousePressed(x, y, button)
    local lx, ly = self:_localCoords(x, y)
    print(string.format("[UICanvas] OnMousePressed raw=(%d,%d) local=(%.2f,%.2f) button=%s", x, y, lx, ly, tostring(button)))
    local totalComps = 0
    for i = #self.gameObjects, 1, -1 do
        local go = self.gameObjects[i]
        if go and go.components then
            totalComps = totalComps + #go.components
            for j = #go.components, 1, -1 do
                local comp = go.components[j]
                if TypeOf(comp, UIElement) and comp.visible and comp.enabled then
                    if comp:ContainsPoint(lx, ly) then
                        print("[UICanvas] -> ContainsPoint = true")
                        if comp:OnMousePressed(lx, ly, button) then
                            print("[UICanvas] -> OnMousePressed handled by comp")
                            return true
                        end
                    else
                        print("[UICanvas] -> ContainsPoint = false")
                    end
                end
            end
        end
    end
    -- check direct UI elements
    for j = #self.uiElements, 1, -1 do
        local comp = self.uiElements[j]
        if TypeOf(comp, UIElement) and comp.visible and comp.enabled then
            if comp:ContainsPoint(lx, ly) then
                if comp:OnMousePressed(lx, ly, button) then
                    return true
                end
            end
        end
    end
    return false
end

function UICanvas:OnMouseReleased(x, y, button)
    local lx, ly = self:_localCoords(x, y)
    for i = #self.gameObjects, 1, -1 do
        local go = self.gameObjects[i]
        if go and go.components then
            for j = #go.components, 1, -1 do
                local comp = go.components[j]
                if TypeOf(comp, UIElement) and comp.visible and comp.enabled then
                    if comp:OnMouseReleased(lx, ly, button) then
                        return true
                    end
                end
            end
        end
    end
    -- direct UI elements
    for j = #self.uiElements, 1, -1 do
        local comp = self.uiElements[j]
        if TypeOf(comp, UIElement) and comp.visible and comp.enabled then
            if comp:OnMouseReleased(lx, ly, button) then
                return true
            end
        end
    end
    return false
end

function UICanvas:OnMouseMoved(x, y, dx, dy)
    local lx, ly = self:_localCoords(x, y)
    for _, go in ipairs(self.gameObjects) do
        if go and go.components then
            for _, comp in ipairs(go.components) do
                if TypeOf(comp, UIElement) and comp.visible and comp.enabled then
                    comp:OnMouseMoved(lx, ly, dx, dy)
                end
            end
        end
    end
    -- direct UI elements
    for _, comp in ipairs(self.uiElements) do
        if TypeOf(comp, UIElement) and comp.visible and comp.enabled then
            comp:OnMouseMoved(lx, ly, dx, dy)
        end
    end
end

function UICanvas:AddElement(elem)
    if not elem then return end
    table.insert(self.uiElements, elem)
    return elem
end

function UICanvas:RemoveElement(elem)
    for i=#self.uiElements,1,-1 do
        if self.uiElements[i] == elem then
            table.remove(self.uiElements, i)
            return true
        end
    end
    return false
end

return UICanvas
