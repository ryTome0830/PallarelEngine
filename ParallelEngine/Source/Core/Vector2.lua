--- @class Vector2
local Vector2 = {}
Vector2.__index = Vector2
Vector2.__name = "Vector2"


-- === construct method ===
-- = new method =

--- @param x? number|nil x座標(default: 0)
--- @param y? number|nil y座標(default: 0)
--- @return Vector2
function Vector2.New(x, y)
    --- @class Vector2
    local instance = setmetatable({}, Vector2)
    instance:Init(x, y)

    return instance
end

--- @private
--- @param x? number
--- @param y? number
function Vector2:Init(x, y)
    self.x = x or 0
    self.y = y or 0
end

-- ===== Special method =====
-- UnityEngine Vector2.zeroなどの静的プロパティと同様な特殊コンストラクタを定義します

--- Vector2.New(0, 0)と同義
--- @return Vector2
function Vector2.Zero() return Vector2.New(0, 0) end
--- Vector2.New(1, 1)と同義
--- @return Vector2
function Vector2.One() return Vector2.New(1, 1) end
--- Vector2.New(0, -1)と同義
--- @return Vector2
function Vector2.Up() return Vector2.New(0, -1) end
--- Vector2.New(0, 1)と同義
--- @return Vector2
function Vector2.Down() return Vector2.New(0, 1) end
--- Vector2.New(-1, 0)と同義
--- @return Vector2
function Vector2.Left() return Vector2.New(-1, 0) end
--- Vector2.New(1, 0)と同義
--- @return Vector2
function Vector2.Right() return Vector2.New(1, 0) end


-- === engine method === 
-- = new method =

--- ベクトルのスカラー倍
--- @param scalar number
--- @return Vector2
function Vector2:Scale(scalar)
    if not TypeOf(scalar, "number") then
        error("[Vector2:Scale()] 引数の型が異なります")
    end
    return Vector2.New(self.x * scalar, self.y * scalar)
end

--- 内積
--- @param v2 Vector2
--- @return number
function Vector2:Dot(v2)
    if not TypeOf(v2, Vector2) then
        error("[Vector2:Dot()] 引数の型が異なります")
    end
    return self.x * v2.x + self.y * v2.y
end

--- 外積
--- @param v2 Vector2
--- @return number
function Vector2:Cross(v2)
    if not TypeOf(v2, Vector2) then
        error("[Vector2:Cross()] 引数の型が異なります")
    end
    return self.x * v2.y - self.y * v2.x
end

--- ベクトルの大きさ
--- @return number
function Vector2:Length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

--- 2ベクトル間の距離
--- @param v2 Vector2
--- @return number
function Vector2:Distance(v2)
    if not TypeOf(v2, Vector2) then
        error("[Vector2:Distance()] 引数の型が異なります")
    end
    return Vector2.New(self.x - v2.x, self.y - v2.y):Length()
end

--- ベクトルの回転
--- @param angle number 回転角(度数法)
--- @return Vector2
function Vector2:Rotate(angle)
    local rad = math.rad(angle)
    local cos = math.cos(rad)
    local sin = math.sin(rad)
    return Vector2.New(
        self.x * cos - self.y * sin,
        self.x * sin + self.y * cos
    )
end

--- ベクトルの正規化
--- @return Vector2
function Vector2:Normalized()
    local len = self:Length()
    if len > 0 then
        return Vector2.New(self.x / len, self.y / len)
    else
        error("[Vector2:Normalized()] 0ベクトルは正規化できません")
        return self
    end
end

--- ベクトルのコピーを作成
--- @return Vector2
function Vector2:Clone()
    return Vector2.New(self.x, self.y)
end



-- === metamethod ===

--- @private
--- @param v2 Vector2
--- @return Vector2
function Vector2:__add(v2)
    if not TypeOf(v2, Vector2) then
        error("[Vector2:__add()] 引数の型が異なります")
    end
    return Vector2.New(self.x + v2.x, self.y + v2.y)
end

--- @private
--- @param v2 Vector2
--- @return Vector2
function Vector2:__sub(v2)
    if not TypeOf(v2, Vector2) then
        error("[Vector2:__sub] 引数の型が異なります")
    end
    return Vector2.New(self.x - v2.x, self.y - v2.y)
end

--- @private
--- @param v2 Vector2
--- @return boolean
function Vector2:__eq(v2)
    if not TypeOf(v2, Vector2) then
        error("[Vector2]: 等価判定の引数が無効です")
    end
    return self.x == v2.x and self.y == v2.y
end

--- @private
function Vector2:__tostring()
    return string.format("Vector2(%f, %f)", self.x, self.y)
end

return Vector2