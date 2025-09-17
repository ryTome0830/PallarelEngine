local Collision = require("Core.Components.Collision")
local MyCollision = Collision:Extend()

function MyCollision:OnCollisionEnter(other)
    print("カスタム衝突: " .. self.gameObject.name .. " vs " .. (other.gameObject and other.gameObject.name or "不明"))
    -- 追加の処理
end

return MyCollision
