--- @class LogManager
local LogManager = require("Core.LogManager")

--- @class TypeRegistry
local TypeRegistry = {}
TypeRegistry.__index = TypeRegistry
TypeRegistry.__name = "TypeRegistry"


--- @type table
local engineNamespace = nil
--- @type table
local gameNamespace = nil

--- 検索対象のテーブルを初期化します
--- @param engineT table エンジンの名前空間 (ParallelEngine)
--- @param gameT table ゲームの名前空間 (Game.Scripts)
function TypeRegistry.Init(engineT, gameT)
    engineNamespace = engineT
    gameNamespace = gameT
    LogManager.Log("TypeRegistry initialized.")
end

--- 文字列名からクラス本体を取得します
--- @param className string クラス名 (例: "SpriteRenderer", "PlayerController")
--- @return Component|nil
function TypeRegistry.Get(className)
    if not engineNamespace or not gameNamespace then
        LogManager.LogError("TypeRegistry is not initialized. Call TypeRegistry.Init() first.")
        return
    end

    -- ゲームの名前空間（ユーザー定義スクリプト）
    local foundClass = gameNamespace[className]
    if foundClass then
        return foundClass
    end

    -- ゲームのScriptsテーブルも探す
    if gameNamespace.Scripts and gameNamespace.Scripts[className] then
        return gameNamespace.Scripts[className]
    end

    -- エンジンのトップレベルを探す
    foundClass = engineNamespace[className]
    if foundClass then
        return foundClass
    end

    -- エンジンのComponentsテーブルなども探す
    if engineNamespace.Components and engineNamespace.Components[className] then
        return engineNamespace.Components[className]
    end

    -- 見つからなければnilを返す
    LogManager.LogWarning("Class '" .. className .. "' not found in any registry.")
    return nil
end

return TypeRegistry
