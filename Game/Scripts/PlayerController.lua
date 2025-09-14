local Component = ParallelEngine.Abstracts.Component

--- @class PlayerController:Component
local PlayerController = Component:Extend()
PlayerController.__index = PlayerController
PlayerController.__name = "PlayerController"

-- 保存したいプロパティを宣言
PlayerController.Serializable = {"_enabled", "speed", "jumpHeight"}

function PlayerController.New(props)
    --- @class PlayerController
    local instance = setmetatable({}, PlayerController)
    instance:Init(props)
    return instance
end

function PlayerController:Init(props)
    self._enabled = props.enabled or true
    self.speed = props.speed or 5.0
    self.jumpHeight = props.jumpHeight or 10.0
    self.internalState = "running"
end

function PlayerController:Update(dt)
    print(string.format("frameTime: %f", dt))
end

function PlayerController:__tostring()
    return string.format("enabled: %s, speed: %s, jumpHeight: %s", self._enabled, self.speed, self.jumpHeight)
end

return PlayerController