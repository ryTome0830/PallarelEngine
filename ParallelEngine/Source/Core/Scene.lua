--- @class Object
local Object = require("Core.Abstracts.Object")
--- @class GameObject
local GameObject = require("Core.GameObject")
--- @class LogManager
local LogManager = require("Core.LogManager")

--- シーン中のオブジェクトの最大数
--- @type integer
local MAX_GAMEOBJECT_NUM = 1000

--- @class Scene:Object
local Scene = Object:Extend()
Scene.__index = Scene
Scene.__name = "Scene"


-- === construct method ===

--- @param name string
--- @param randomSeed number
--- @param saveRandomeSeed boolean
--- @return Scene
function Scene.New(name, randomSeed, saveRandomeSeed)
    --- @class Scene
    local instance = setmetatable({}, Scene)
    instance:Init(name, randomSeed, saveRandomeSeed)

    return instance
end

--- @protected
--- @param name string
--- @param randomSeed number
--- @param saveRandomeSeed boolean
function Scene:Init(name, randomSeed, saveRandomeSeed)
    self.super:Init()

    self.name = name

    self.saveRandomeSeed = saveRandomeSeed or false
    self.randomSeed = randomSeed

    --- @type GameObject[]
    self.gameObjects = {}

    --- @type GameObject[]
    self.pendingGameObjects = {}
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
    if #self.gameObjects + #self.pendingGameObjects >= MAX_GAMEOBJECT_NUM then
        LogManager.LogError("1シーンに存在できるGameObjectは " .. MAX_GAMEOBJECT_NUM .. " に制限されています")
        return
    end

    table.insert(self.gameObjects, gameObject)
end

--- @param name string
--- @return GameObject|nil
function Scene:FindGameObjectByName(name)
    for _, go in ipairs(self.gameObjects) do
        if go.name == name then
            return go
        end
    end
    return nil
end

--- @param uuid string
--- @return GameObject|nil
function Scene:FindGameObjectByUUID(uuid)
    for _, go in ipairs(self.gameObjects) do
        if go.uuid == uuid then
            return go
        end
    end
    return nil
end

--- @private
function Scene:Awake()

end

--- @private
function Scene:Start()
end

--- @param dt number
function Scene:Update(dt)
    if #self.pendingGameObjects > 0 then
        for _, go in ipairs(self.pendingGameObjects) do
            go:Awake()
            go._awaked = true
        end

        for _, go in ipairs(self.pendingGameObjects) do
            go:Start()
            go._started = true
        end

        for _, go in ipairs(self.pendingGameObjects) do
            table.insert(self.gameObjects, go)
        end
        self.pendingGameObjects = {}
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