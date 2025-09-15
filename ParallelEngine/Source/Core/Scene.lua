--- @class Object
local Object = require("Core.Abstracts.Object")
--- @class GameObject
local GameObject = require("Core.GameObject")

--- シーン中のオブジェクトの最大数
--- @type integer
local MAX_GAMEOBJECT_NUM = 100

--- @class Scene:Object
local Scene = Object:Extend()
Scene.__index = Scene
Scene.__name = "Scene"


-- === construct method ===

--- @param name string
--- @return Scene
function Scene.New(name)
    --- @class Scene
    local instance = setmetatable({}, Scene)
    instance:Init(name)

    return instance
end

--- @protected
--- @param name string
function Scene:Init(name)
    self.super:Init()

    self.name = name
    self._awaked = false
    self._started = false

    --- @type GameObject[]
    self.gameObjects = {}
end



-- === engine method === 

--- @param prefab GameObject
--- @param ... table
--- @return GameObject|nil
function Scene:Instantiate(prefab, ...)
    if TypeOf(prefab, GameObject) then
        return prefab.New(table.unpack(...))
    end
    return nil
end

--- @param gameObject GameObject
function Scene:AddGameObject(gameObject)
    if #self.gameObjects >= MAX_GAMEOBJECT_NUM then
        error("1シーンに存在できるGameObjectは " .. MAX_GAMEOBJECT_NUM .. " に制限されています")
        return
    end

    table.insert(self.gameObjects, gameObject)
end

function Scene:Awake()
    if self._awaked then
        error("Scene: " .. self.name .. " is already awaked.")
        return
    end

    for _, go in ipairs(self.gameObjects) do
        go:Awake()
    end
    self:OnAwake()
    self._awaked = true
end

function Scene:Start()
    if not self._awaked then
        error("Scene: " .. self.name .. " is not awaked yet.")
        return
    end
    if self._started then
        error("Scene: " .. self.name .. " is already started.")
        return
    end

    for _, go in ipairs(self.gameObjects) do
        go:Start()
    end
    self:OnStart()
    self._started = true
end

--- @param dt number
function Scene:Update(dt)
    if not self._awaked or not self._started then
        error("Scene: " .. self.name .. " cannot be executed unless Awake and Start are executed.")
        return
    end

    for _, go in ipairs(self.gameObjects) do
        go:Update(dt)
    end
end

function Scene:Draw()
    for _, go in ipairs(self.gameObjects) do
        go:Draw()
    end
    self:OnDraw()
end

function Scene:Destroy()
    for _, go in ipairs(self.gameObjects) do
        go:Destroy()
    end
    self.gameObjects = nil
    self:OnDestroy()
end



-- === callbacks ===

function Scene:OnAwake()
end

function Scene:OnStart()
end

--- @param dt number
function Scene:OnUpdate(dt)
end

function Scene:OnDraw()
end

function Scene:OnDestroy()
end



-- === metamethod ===

function Scene:__tostring()
    -- return "'Scene':" .. ExpandTable(self.gameObjects, 3)
    return string.format(
        "'Scene(name: %s, gameObjectsNum: %d)'",
        self.name,
        #self.gameObjects
    )
end



return Scene