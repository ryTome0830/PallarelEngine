--- @class Object
local Object = {}
Object.__index = Object
Object.__name = "Object"


-- === construct method ===
-- = new method =

--- @private
function Object.New()
end

--- @protected
function Object:Init()
    self._enabled = true
end

--- @return Object
function Object:Extend()
    --- @class Object
    local cls = {}

    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end

    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)

    return cls
end

--- @param T table
--- @return boolean
function Object:Is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end



-- === engine method === 
-- = new method =

function Object:Awake() end
function Object:Start() end
--- @param dt number 経過時間 love.updateより参照
function Object:Update(dt) end
function Object:Destroy() self:OnDestroy() end
function Object:IsEnabled() return self._enabled end
--- @param state boolean
function Object:SetActive(state) self._enabled = state end


-- === callback ===
-- = new method =

--- @private
function Object:OnInit() end
--- @private
function Object:OnEnable() end
--- @private
function Object:OnDisable() end
--- @private
function Object:OnDestroy() end



-- === metamethod ===

--- @protected
function Object:__tostring()
    return "PallarelEngine 'Object' enabled: " .. tostring(self._enabled)
end

--- @private
function Object:__newindex(key, value)
    if key == "_enabled" then
        if self._enabled == value then return end

        if value == true then
            rawset(self, key, value);
            self:OnEnable()
        elseif value == false then
            rawset(self, key, value);
            self:OnDisable()
        else
            error("The argument is wrong! '_enabled' must be a boolean value!")
        end
    else
        rawset(self, key, value)
    end
end

return Object