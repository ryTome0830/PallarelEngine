--- @alias ComponentName string
--- @alias ComponentProperties table<string, Component>

--- コンポーネントの定義を表す型。
--- キーにコンポーネント名、値にプロパティのテーブルを指定します。
--- @class ComponentsDefinition
--- @field [ComponentName] ComponentProperties
local ComponentsDefinition = {}

-- シーンデータファイル内の、単一のGameObjectの定義を表す型。
--- @class GameObjectDefinition
--- @field property table
--- @field name? string GameObjectの名前 (例: "Player")
--- @field position? Vector2
--- @field rotation? number
--- @field scale? Vector2
--- @field components? ComponentsDefinition
local GameObjectDefinition = {}


--- 1つのシーンを定義するデータテーブルの型。
--- @class SceneDefinition
--- @field name string シーンの名前 (例: "Level 1")
--- @field gameObjects GameObjectDefinition[] このシーンに配置されるGameObject定義のリスト
local SceneDefinition = {}


--- このテーブルは実際には使用しませんが、型定義のために返します。
-- return {
--     SceneDefinition = SceneDefinition,
--     GameObjectDefinition = GameObjectDefinition,
--     ComponentsDefinition = ComponentsDefinition,
-- }

--- @type SceneDefinition
local scene = {
    name = "aaa",
    gameObjects = {
    }
}