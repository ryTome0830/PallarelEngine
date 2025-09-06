--- @class Object
local Object = require("Core.Abstracts.Object")
--- @class Transform
local Transform = require("Core.Transform")
--- @class Vector2
local Vector2 = require("Core.Vector2")
--- @class Component
local Component = require("Core.Abstracts.Component")

--- コンポーネントの最大数
--- @type integer
local MAX_COMPONENT_NUM = 6

--- @class GameObject:Component
local GameObject = Object:Extend()
GameObject.__index = GameObject
GameObject.__name = "GameObject"


-- === construct method ===
-- = override method =

--- @param name string
--- @param position? Vector2
--- @param rotation? number
--- @param scale? Vector2
--- @return GameObject
function GameObject.New(name, position, rotation, scale)
    --- @class GameObject
    local instance = setmetatable({}, GameObject)
    instance:Init(name, position, rotation, scale)

    return instance
end

--- @protected
--- @param name string
--- @param position? Vector2
--- @param rotation? number
--- @param scale? Vector2
function GameObject:Init(name, position, rotation, scale)
    self.super:Init()

    --- @type boolean
    self._isDestroyed = false

    --- @type string
    self.name = name

    --- @type string
    self.uuid = self:GenerateUUID()

    --- @type Transform
    self.transform = Transform.New(
        self,
        position or Vector2.Zero(),
        rotation or 0,
        scale or Vector2.One()
    )

    --- @type Component[]
    self.components = {}
end


-- = new method =

--- @private
--- @return string
function GameObject:GenerateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    local uuid = string.gsub(
        template,
        "[xy]",
        function (c)
            local r = math.random(0, 15)
            local v = (c == "x") and r or (math.floor(r % 4) + 8)
            return string.format("%x", v)
        end
    )

    return uuid
end

-- === engine method === 
-- = new method =

--- コンポーネントをGameObjectに追加する
--- @param componentClass Component
--- @param ... table ComponentClassのNewに渡す引数
--- @return Component|nil
function GameObject:AddComponent(componentClass, ...)
    if #self.components >= MAX_COMPONENT_NUM then
        error("GameObjectに設定できるComponentは最大 "..MAX_COMPONENT_NUM.." に制限されています")
        return nil
    end

    if TypeOf(componentClass, Transform) then
        error("GameObjectにTransformを複数追加することはできません")
        return nil
    end

    --- @class Component
    local newComponent = componentClass.New(...)
    if not newComponent:Is(Component) then
        error("GameObjectに追加できるのはComponentを継承したクラスのみです")
        return nil
    end

    newComponent.gameObject = self
    newComponent.transform = self.transform

    table.insert(self.components, newComponent)

    if newComponent.Awake then
        newComponent:Awake()
    end

    return newComponent
end

--- アタッチされた任意のコンポーネントを取得する
--- @param componentClass Component
--- @return Component|nil
function GameObject:GetComponent(componentClass)
    for _, component in pairs(self.components) do
        if componentClass:Is(Component) then
            return component
        end
    end
    return nil
end


-- = override method =

function GameObject:Awake()
    -- only false and false
    if not self._enabled and not self._awaked then return end

    for _, component in ipairs(self.components) do
        if component:IsEnabled() then
            component:Awake()
        end
    end

    self._awaked = true
end

function GameObject:Start()
    if not self._enabled and not self._started then return end

    for _, component in ipairs(self.components) do
        if component:IsEnabled() then
            component:Start()
        end
    end

    self._awaked = true
    self._started = true
end

function GameObject:Update(dt)
    if not self._enabled then return end

    for _, component in ipairs(self.components) do
        if component:IsEnabled() then
            component:Update(dt)
        end
    end
end

function GameObject:Destroy()
    -- destroy children

    -- destroy component



    self:OnDestroy()

    self.transform:Destroy()
    self.components = nil
    self.transform = nil
    self.super:Destroy()
end

function GameObject:IsEnabled()
    return self._enabled
end

--- @param state boolean
function GameObject:SetActive(state)
    self._enabled = state
end



-- === callback ===
-- = override method =

--- @private
function GameObject:OnInit()

end

--- @private
function GameObject:OnEnable()
    for _, component in ipairs(self.components) do
        if component:IsEnabled() then
            component:SetActive(true)
        end
    end
end

--- @private
function GameObject:OnDisable()
    for _, component in ipairs(self.components) do
        if component:IsEnabled() then
            component:SetActive(false)
        end
    end
end

--- @private
function GameObject:OnDestroy()
    self._isDestroyed = true
end



-- === metamethod ===

--- @private
function GameObject:__tostring()
    return string.format(
        "GameObject(name: %s, enabled: %s, transform: %s, components: %s)",
        self.name,
        self._enabled,
        self.transform,
        ExpandTable(self.components)
    )
end

return GameObject