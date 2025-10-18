--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class Vector2
local Vector2 = require("Core.Vector2")
--- @class Event
local Event = require("Core.Utils.Event")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class Transform:Component
local Transform = Component:Extend()
Transform.__index = Transform
Transform.__name = "Transform"


-- === construct method ===

--- @param gameObjectInstance GameObject
--- @param position? Vector2
--- @param rotation? number
--- @param scale? Vector2
--- @return Transform
function Transform.New(gameObjectInstance, position, rotation, scale)
    if not gameObjectInstance then
        LogManager.LogError("TransformはGameObjectからのみ生成できます Transform.New()を直接呼び出すことはできません")
    end

    if gameObjectInstance.transform then
        LogManager.LogError("GameObjectには既にTransformがアタッチされています Transformを複数追加することはできません")
    end

    --- @class Transform
    local instance = setmetatable({}, Transform)
    instance:Init(
        gameObjectInstance,
        position,
        rotation,
        scale
    )

    return instance
end

--- @private
--- @param gameObjectInstance GameObject
--- @param position? Vector2
--- @param rotation? number
--- @param scale? Vector2
function Transform:Init(gameObjectInstance, position, rotation, scale)
    self.super:Init()
    --- @type Event
    self.onPositionChanged = Event.New()
    --- @type Event
    self.onRotationChanged = Event.New()
    --- @type Event
    self.onScaleChanged = Event.New()

    self.gameObject = gameObjectInstance
    self.position = position or Vector2.Zero()
    self.rotation = rotation or 0
    self.scale = scale or Vector2.One()

    --- @type Transform|nil
    self.parent = nil
    --- @type Transform[]
    self.children = {}
end

--- @param position Vector2
function Transform:SetPosition(position)
    self.position = position
    self.onPositionChanged:Invoke(self)
end

--- @param rotation number
function Transform:SetRotation(rotation)
    self.rotation = rotation
    self.onRotationChanged:Invoke(self)
end
--- @param scale Vector2
function Transform:SetScale(scale)
    self.scale = scale
    self.onScaleChanged:Invoke(self)
end

-- = override =

--- @return TransformDefinition
function Transform:Dump()
    return {
        position = {x = self.position.x, y = self.position.y},
        rotation = self.rotation,
        scale = {x = self.scale.x, y = self.scale.y}
    }
end


-- === engine method === 
-- = new method =

--- 親オブジェクトを設定
--- @param newParent Transform|nil nilを指定すると親子関係を解除
function Transform:SetParent(newParent)
    if self.parent then
        for i, child in ipairs(self.parent.children) do
            if child == self then
                table.remove(self.parent.children, i)
                break
            end
        end
    end

    self.parent = newParent

    if self.parent then
        table.insert(self.parent.children, self)
    end
end



--- = override method =

function Transform:Destroy()
    self.super:OnDestroy()

    -- 親オブジェクトの参照を切る
    if self.parent then
        local i, reference = FindInTable(self.parent.children, function (child)
            return child == self
        end)
        if i then
            table.remove(self.parent.children, i)
            reference = nil
        end
    end

    -- 参照を切る
    self.gameObject = nil
    self.position = nil
    self.scale = nil
    self.parent = nil
    self.children = {}
end

-- === callback ===



-- === metamethod ===

--- @private
function Transform:__tostring()
    -- return string.format("Transform(pos: %s, rotation: %.2f°, scale: %s)",
    --     tostring(self.position), math.deg(self.rotation), tostring(self.scale)
    -- )
    return "Transform"
end

--- @private
function Transform:__newindex(key, value)
    if key == "_enabled" then
        LogManager.LogWarning("Transformの'_enabled'プロパティは機能しません")
        return
    end
    if key == "scale" then
        if not TypeOf(value, Vector2) then
            LogManager.LogError("Transform.scaleにはVector2型の値を設定してください")
            return
        end
        if value.x == 0 or value.y == 0 then
            LogManager.LogWarning("Transformのscaleに0が設定されようとしたため(0.1, 0.1)に自動補正しました")
            value = Vector2.New(0.1, 0.1)
        end
        rawset(self, key, value)
        self.onScaleChanged:Invoke(self)
    elseif key == "position" then
        if not TypeOf(value, Vector2) then
            LogManager.LogError("Transform.positionにはVector2型の値を設定してください")
            return
        end
        rawset(self, key, value)
        self.onPositionChanged:Invoke(self)
    elseif key == "rotation" then
        if type(value) ~= "number" then
            LogManager.LogError("Transform.rotationにはnumber型の値を設定してください")
            return
        end
        rawset(self, key, value)
        self.onRotationChanged:Invoke(self)
    else
        rawset(self, key, value)
    end
end


return Transform