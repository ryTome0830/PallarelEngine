--- @class Component
local Component = require("Core.Abstracts.Component")
--- @class Vector2
local Vector2 = require("Core.Vector2")

--- @class Transform:Component
local Transform = Component:Extend()
Transform.__index = Transform
Transform.__name = "Transform"


-- === construct method ===
-- = new method =


-- = override method =

--- @param gameObjectInstance GameObject
--- @param position? Vector2
--- @param rotation? number
--- @param scale? Vector2
--- @return Transform
function Transform.New(gameObjectInstance, position, rotation, scale)
    if not gameObjectInstance then
        error("TransformはGameObjectからのみ生成できます Transform.New()を直接呼び出すことはできません")
    end

    if gameObjectInstance.transform then
        error("GameObjectには既にTransformがアタッチされています Transformを複数追加することはできません")
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

    self.gameObject = gameObjectInstance
    self.position = position or Vector2.Zero()
    self.rotation = rotation or 0
    self.scale = scale or Vector2.One()

    --- @type Transform|nil
    self.parent = nil
    --- @type Transform[]
    self.children = {}
end

-- function Transform:Extend() end
-- function Transform:Is(T) end

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


-- = override method =

-- function Transform:Awake() end
-- function Transform:Start() end
-- function Transform:Update(dt) end
-- function Transform:Destroy() self:OnDestroy() end
-- function Transform:IsEnabled() end



-- === callback ===
-- = new method =


-- = override method =

-- function Transform:OnInit() end
-- function Transform:OnEnable() end
-- function Transform:OnDisable() end
-- function Transform:OnDestroy() end


-- === metamethod ===

--- @private
function Transform:__tostring()
    return string.format("Transform(pos: %s, rotation: %f, scale: %s)",
        tostring(self.position), self.rotation, tostring(self.scale)
    )
end

--- @private
function Transform:__newindex(key, value)
    if key == "_enabled" then
        error("Transformの'_enabled'プロパティは機能しません")
        return
    elseif key == "scale" then
        if not TypeOf(value, Vector2) then
            error("型が一致しません")
            return
        end
        if value.x == 0 or value.y == 0 then
            print("Transformのscaleに0が設定されようとしたため(0.1, 0.1)に自動補正しました")
            rawset(self, key, Vector2.New(0.1, 0.1))
            return
        end
    end
    rawset(self, key, value)
end

return Transform