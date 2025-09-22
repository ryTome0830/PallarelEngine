--- @class Event
local Event = {}
Event.__index = Event
Event.__name = "Event"


--- @return Event
function Event.New()
    --- @class Event
    local instance = setmetatable({}, Event)
    instance:Init()
    return instance
end

function Event:Init()
    self.subscribers = {}
end

--- イベントにリスナーを登録
--- @param listener function
function Event:Subscribe(listener)
    table.insert(self.subscribers, listener)
end

--- イベントを発行しリスナーを呼び出す
--- @param ... any
function Event:Invoke(...)
    for _, listener in ipairs(self.subscribers) do
        listener(...)
    end
end


return Event