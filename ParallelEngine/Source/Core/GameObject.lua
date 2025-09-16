--- @class Orbit
local Orbit = require("Core.Abstracts.Orbit")
--- @class Transform
local Transform = require("Core.Transform")
--- @class Vector2
local Vector2 = require("Core.Vector2")
--- @class Component
local Component = require("Core.Abstracts.Component")

--- @class LogManager
local LogManager = require("Core.LogManager")

--- コンポーネントの最大数
--- @type integer
local MAX_COMPONENT_NUM = 6

--- @class GameObject:Orbit
local GameObject = Orbit:Extend()
GameObject.__index = GameObject
GameObject.__name = "GameObject"


-- === construct method ===

--- @param name string
--- @param position? Vector2
--- @param rotation? number
--- @param scale? Vector2
--- @param initEnabled? boolean 
--- @return GameObject
function GameObject.New(name, position, rotation, scale, initEnabled)
    --- @class GameObject
    local instance = setmetatable({}, GameObject)
    instance:Init(name, position, rotation, scale, initEnabled)

    return instance
end

--- @protected
--- @param name string
--- @param position? Vector2
--- @param rotation? number
--- @param scale? Vector2
--- @param initEnabled? boolean
function GameObject:Init(name, position, rotation, scale, initEnabled)
    self.super:Init()

    --- @type boolean
    self._isDestroyed = false

    --- @type string
    self.name = name

    --- @type string
    self.uuid = self:GenerateUUID()

    if initEnabled == nil then
        self._enabled = true
    else
        self._enabled = initEnabled
    end

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

--- @return GameObject
function GameObject:Clone()
    local go = GameObject.New(
        self.name .. "(clone)",
        self.transform.position:Clone(),
        self.transform.rotation,
        self.transform.scale:Clone(),
        self._enabled
    )

    for _, component in ipairs(self.components) do
        local properties = component:Clone()
        local componentClass = component.__index
        if componentClass then
            go:AddComponent(componentClass, properties)
        end
    end

    return go
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


-- = override =

--- @param isStrict? boolean
--- @return GameObjectDefinition|nil
function GameObject:Dump(isStrict)
    isStrict = isStrict or false

    --- @type GameObjectDefinition
    local goData = {}

    if self.name and self.name ~= "" then
        goData.name = string.format("%s", self.name)
    else
        if isStrict then
            LogManager.LogError("Error: GameObejct.name is missing")
            return nil
        end
        goData.name = "AnonymousGameObject_broken"
    end

    --- @type GameObjectPropertiesDefinition
    local properties = {}
    if TypeOf(self.transform, Transform)then
        properties.transform = self.transform:Dump()
    else
        if isStrict then
            LogManager.LogError("Error: GameObject.transform is missing.")
            return nil
        end
        properties.transform = {position={x=0, y=0}, rotation=0, scale={x=1, y=1}}
    end
    if self._enabled ~= nil then
        properties._enabled = self._enabled
    else
        if isStrict then
            LogManager.LogError("Error: GameObject._enabled state is missing.")
            return nil
        end
        properties._enabled = true
    end

    goData.properties = properties

    --- @type ComponentDefinition
    local componentsData = {}
    if self.components then
        for _, component in ipairs(self.components) do
            local componentType = component.__name
            local properties = component:Dump()

            if componentType then
                table.insert(componentsData, {
                    componentType = componentType,
                    properties = properties
                })
            end
        end
    end

    if next(componentsData) ~= nil then
        goData.components = componentsData
    end

    return goData
end


-- === engine method === 
-- = new method =

--- コンポーネントをGameObjectに追加する
--- @generic T:Component
--- @param componentClass T
--- @param properties table ComponentClassのNewに渡す引数
--- @return T|nil
function GameObject:AddComponent(componentClass, properties)
    if #self.components >= MAX_COMPONENT_NUM then
        LogManager.LogError("GameObjectに設定できるComponentは最大 "..MAX_COMPONENT_NUM.." に制限されています")
        return nil
    end

    if TypeOf(componentClass, Transform) then
        LogManager.LogError("GameObjectにTransformを複数追加することはできません")
        return nil
    end

    --- @class Component
    local newComponent = componentClass.New(self, properties)
    if not newComponent:Is(Component) then
        LogManager.LogError("GameObjectに追加できるのはComponentを継承したクラスのみです")
        return nil
    end

    if FindInTable(self.components, function(c) return TypeOf(c, componentClass) end) then
        LogManager.LogError("GameObjectに同じ種類のComponentを複数追加することはできません")
        return nil
    end

    newComponent.gameObject = self

    table.insert(self.components, newComponent)
    newComponent:Awake()

    return newComponent
end

--- アタッチされた任意のコンポーネントを取得する
--- @generic T:Component
--- @param componentClass T
--- @return T|nil
function GameObject:GetComponent(componentClass)
    for _, component in ipairs(self.components) do
        if TypeOf(component, componentClass) then
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
    if not self._enabled or self._isDestroyed then return end

    for _, component in ipairs(self.components) do
        if component:IsEnabled() then
            component:Update(dt)
        end
    end
end

function GameObject:Draw()
    if not self._enabled or self._isDestroyed then return end

    for _, component in ipairs(self.components) do
        if component:IsEnabled() then
            component:Draw()
        end
    end
end

function GameObject:Destroy()
    -- 子を破壊
    for _, child in ipairs(self.transform.children) do
        child:Destroy()
    end

    -- コンポーネントを破壊
    for _, component in ipairs(self.components) do
        component:Destroy()
    end

    -- 参照を切る
    self.transform:Destroy()
    self.transform = nil
    self.components = nil
    self.name = nil
    self.uuid = nil
    self.super:Destroy()
end


-- === callback ===
-- = override method =

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



-- === metamethod ===

--- @private
function GameObject:__tostring()
    return string.format(
        "GameObject(name: %s, uuid: %s, enabled: %s, transform: %s, components: %s)",
        self.name,
        self.uuid,
        self._enabled,
        self.transform,
        ExpandTable(self.components)
    )
end



return GameObject