--- @class TypeRegistry
local TypeRegistry = require("Core.TypeRegistry")

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
    self.currentScene = Scene.New(sceneTable.name)
    self:ParseSecne(sceneTable)
end

--- @param sceneTable SceneDefinition
function SceneManager:ParseSecne(sceneTable)
    for _, goDef in ipairs(sceneTable.gameObjects) do
        local newGO = GameObject.New(
            goDef.name,
            Vector2.New(goDef.properties.transform.position.x, goDef.properties.transform.position.y),
            goDef.properties.transform.rotation,
            Vector2.New(goDef.properties.transform.scale.x, goDef.properties.transform.scale.y)
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
function SceneManager:DumpScene(dirPath)
    if not self.currentScene then return end
    if not TypeOf(self.currentScene.name, "string") then return end

    --- @type file*|nil
    local f = CheckExistanceFile(dirPath, self.currentScene.name)
    if not f then return end

    local sceneData = {
        name = self.currentScene.name,
        gameObjects = {}
    }

    for _, go in ipairs(self.currentScene.gameObjects) do
        -- go:Dump() は GameObjectのシリアライズメソッドを想定
        local goData = go:Dump()
        table.insert(sceneData.gameObjects, goData)
    end

    local sceneContext = "return " .. ToStringTable(sceneData)

    f:write(sceneContext)
    f:close()
end

function SceneManager:SerializeScene()
end

function SceneManager:Deserialize()
end


return SceneManager