--- @class Scene
local Scene = require("Core.Scene")
--- @class GameObject
local GameObject = require("Core.GameObject")

--- @class SceneManager:Object
local SceneManager = {}
SceneManager.__index = SceneManager
SceneManager.__name = "SceneManager"


--- @return SceneManager
function SceneManager.New()
    --- @class SceneManager
    local instance = setmetatable({}, SceneManager)
    instance:Init()

    return instance
end

function SceneManager:Init()
    self.super:Init()
    --- @type Scene
    self.currentScene = nil
end

function SceneManager:ParseSecne(sceneTable)
    for _, goDef in ipairs(sceneTable.gameObjects) do
        local newGO = GameObject.New(
            goDef.name,
            goDef.properties.position,
            goDef.properties.rotation,
            goDef.properties.scale
        )

        if goDef.components then
            for _, compDef in ipairs(goDef.components) do
                newGO:AddComponent(compDef.componentType, unpack(compDef.properties))
            end
        end
        self.currentScene:AddGameObject(newGO)
    end
end

function SceneManager:DumpScene()
    if not self.currentScene then return end
    if not TypeOf(self.currentScene.name, "string") then return end

    local f = CheckExistanceFile(self.currentScene.name)
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

    local sceneContext = "return " .. DumpTable(sceneData)

    f:write(sceneContext)
    f:close()
end

--- @param t table
--- @param indent_level number (default=0)
--- @return string
function DumpTable(t, indent_level)
    indent_level = indent_level or 0
    local indent = string.rep("    ", indent_level)
    local next_indent = string.rep("    ", indent_level + 1)
    local parts = {}
    local is_array = true
    
    -- キーが1から始まる整数かチェック
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k ~= math.floor(k) or k < 1 then
            is_array = false
            break
        end
    end
    
    for k, v in (is_array and ipairs or pairs)(t) do
        local key_str
        if not is_array then
            key_str = type(k) == "string" and '["' .. k .. '"]' or tostring(k)
        else
            key_str = nil -- 配列形式ではキーは省略
        end

        local val_str
        if type(v) == "table" then
            val_str = DumpTable(v, indent_level + 1)
        elseif type(v) == "string" then
            val_str = '"' .. v .. '"'
        else
            val_str = tostring(v)
        end
        
        local line = next_indent
        if key_str then
            line = line .. key_str .. " = " .. val_str
        else
            line = line .. val_str
        end
        table.insert(parts, line)
    end
    
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
end

--- @param fileName string
--- @return file|nil
function CheckExistanceFile(fileName)
    local attempts = 0
    local finalFileName = fileName .. ".lua"
    
    while attempts < 3 do
        local f = io.open(finalFileName, "r")
        if not f then
            return io.open(finalFileName, "w")
        else
            f:close()
            attempts = attempts + 1
            finalFileName = string.format("%s_%d.lua", fileName, attempts)
        end
    end
    
    print("Failed to create file after 3 attempts.")
    return nil
end

function SceneManager:SerializeScene()
end

function SceneManager:Deserialize()
end

function SceneManager:LoadScene(sceneName)
end