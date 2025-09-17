--- @class TypeRegistry
local TypeRegistry = require("Core.TypeRegistry")
--- @class Physics
local Physics = require("Core.Physics")
--- @class Scene
local Scene = require("Core.Scene")
--- @class GameObject
local GameObject = require("Core.GameObject")
--- @class Vector2
local Vector2 = require("Core.Vector2")

--- @class SceneManager
local SceneManager = {}
SceneManager.__index = SceneManager
SceneManager.__name = "SceneManager"

--- @class SceneManager
local SingletonInstance


--- @return SceneManager
function SceneManager.New()
    if not SingletonInstance then
        local instance = setmetatable({}, SceneManager)
        instance:Init()
        SingletonInstance = instance
    end

    return SingletonInstance
end

--- @private
function SceneManager:Init()
    --- @type Scene
    self.currentScene = nil
end

--- @param sceneTable SceneDefinition
function SceneManager:LoadScene(sceneTable)
    local randomSeed
    if sceneTable.saveRandomeSeed then
        randomSeed = sceneTable.randomSeed
    else
        randomSeed = os.time() % 10000
    end
    self.currentScene = Scene.New(sceneTable.name, randomSeed, sceneTable.saveRandomeSeed)
    self:ParseSecne(sceneTable)
end

function SceneManager:UnLoadScene()
    self.currentScene:Destroy()
    self.currentScene = nil
end

--- @param dt number
function SceneManager:UpdateScene(dt)
    self.currentScene:Update(dt)
    Physics.Update(dt)
end

function SceneManager:DrawScene()
    self.currentScene:Draw()
    Physics.DrawCollisionMesh()
end

--- @param sceneTable SceneDefinition
function SceneManager:ParseSecne(sceneTable)
    for _, goDef in ipairs(sceneTable.gameObjects) do
        local newGO = GameObject.New(
            goDef.name,
            Vector2.New(goDef.properties.transform.position.x, goDef.properties.transform.position.y),
            goDef.properties.transform.rotation,
            Vector2.New(goDef.properties.transform.scale.x, goDef.properties.transform.scale.y),
            goDef.properties._enabled
        )

        if goDef.components then
            for _, compDef in ipairs(goDef.components) do
                local componentClass = TypeRegistry.Get(compDef.componentType)
                if componentClass then
                    newGO:AddComponent(componentClass, compDef.properties)
                end
            end
        end
        self.currentScene:AddGameObject(newGO)
    end
end

--- @param dirPath string
--- @param prioritiseGameObjects? table<string>
function SceneManager:DumpScene(dirPath, prioritiseGameObjects)
    if not self.currentScene then return end
    if not TypeOf(self.currentScene.name, "string") then return end

    --- @type file*|nil
    --local f = CheckExistanceFile(dirPath, self.currentScene.name)
    -- if not f then return end

    local sceneData = {
        name = self.currentScene.name,
        randomSeed = self.currentScene.randomSeed,
        saveRandomeSeed = self.currentScene.saveRandomeSeed,
        gameObjects = {}
    }

    local sortedGameObjects = {}
    local others = {}

    local priorityMap = {}
    if prioritiseGameObjects then
        for i, name in ipairs(prioritiseGameObjects) do
            priorityMap[name] = i
        end
    end

    for _, go in ipairs(self.currentScene.gameObjects) do
        if go.name == "GameManager" then
            table.insert(sortedGameObjects, go)
        elseif priorityMap[go.name] then
            table.insert(sortedGameObjects, 1 + priorityMap[go.name], go)
        else
            table.insert(others, go)
        end
    end

    for _, go in ipairs(others) do
        table.insert(sortedGameObjects, go)
    end

    print(#sortedGameObjects)
    for _, go in ipairs(sortedGameObjects) do
        local goData = go:Dump()
        table.insert(sceneData.gameObjects, goData)
    end

    local sceneContext = "return " .. ToStringTable(sceneData)
    print(sceneContext)
    -- f:write(sceneContext)
    -- f:close()
end

function SceneManager:SerializeScene()
end

function SceneManager:Deserialize()
end


return SceneManager