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
    --- @type number
    self.updateInterval = 0.02
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


local accumulatedTime = 0
function SceneManager:UpdateScene(dt)
    accumulatedTime = accumulatedTime + dt
    if accumulatedTime >= self.updateInterval then
        Physics.Update(accumulatedTime)
        self.currentScene:Update(accumulatedTime)
        accumulatedTime = 0
    end
end

function SceneManager:DrawScene()
    Physics.DrawCollisionMesh()
    self.currentScene:Draw()
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
    local f = CheckExistanceFile(dirPath, self.currentScene.name)
    if not f then return end

    --- @type SceneDefinition
    local sceneData = {
        name = self.currentScene.name,
        randomSeed = self.currentScene.randomSeed,
        saveRandomeSeed = self.currentScene.saveRandomeSeed,
        gameObjects = {}
    }

    -- 優先順位を管理するマップを作成 (GameManagerを最優先とする)
    local priorityMap = { ["GameManager"] = 0 }
    if prioritiseGameObjects then
        for i, name in ipairs(prioritiseGameObjects) do
            -- GameManagerより後の優先度を割り当てる
            priorityMap[name] = i
        end
    end

    --- @type GameObject[]
    local prioritizedList = {}
    --- @type GameObject[]
    local othersList = {}

    -- Step 1: 1回のループでオブジェクトを優先リストと通常リストに振り分ける (O(N))
    for _, go in ipairs(self.currentScene.gameObjects) do
        if priorityMap[go.name] ~= nil then
            table.insert(prioritizedList, go)
        else
            table.insert(othersList, go)
        end
    end

    -- Step 2: 優先リスト内をpriorityMapに基づいてソートする (O(P log P))
    -- PはprioritizedListの要素数
    table.sort(prioritizedList, function(a, b)
        return priorityMap[a.name] < priorityMap[b.name]
    end)

    -- Step 3: 優先リストと通常リストを結合する (O(N))
    -- まず優先リストの要素を追加
    for _, go in ipairs(prioritizedList) do
        local goData = go:Dump()
        table.insert(sceneData.gameObjects, goData)
    end
    -- 次に通常リストの要素を追加
    for _, go in ipairs(othersList) do
        local goData = go:Dump()
        table.insert(sceneData.gameObjects, goData)
    end

    local sceneContext = "return " .. TableToString(sceneData)
    f:write(sceneContext)
    f:close()
end

function SceneManager:SerializeScene()
end

function SceneManager:Deserialize()
end


return SceneManager