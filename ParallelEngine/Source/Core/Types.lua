--- 1つのシーンを定義するデータテーブルの型。
--- @class SceneDefinition
--- @field name string
--- @field randomSeed number
--- @field saveRandomeSeed boolean
--- @field gameObjects GameObjectDefinition[]
local SceneDefinition = {}

-- シーンデータファイル内の、単一のGameObjectの定義を表す型
--- @class GameObjectDefinition
--- @field name? string
--- @field properties? GameObjectPropertiesDefinition
--- @field components? ComponentDefinition[]
local GameObjectDefinition = {}

--- GameObjectのプロパティを定義する型
--- @class GameObjectPropertiesDefinition
--- @field transform? TransformDefinition
--- @field _enabled? boolean
local GameObjectPropertiesDefinition = {}

--- Transformのプロパティを定義する型
--- @class TransformDefinition
--- @field position Vector2Definition
--- @field rotation number
--- @field scale Vector2Definition
local TransformDefinition = {}

--- Vector2のプロパティを定義する型
--- @class Vector2Definition
--- @field x number
--- @field y number
local Vector2Definition = {}

--- コンポーネントの定義を表す型
--- キーにコンポーネント名、値にプロパティのテーブルを指定します
--- @class ComponentDefinition
--- @field componentType? string
--- @field properties? table
local ComponentDefinition = {}



-- ===== Components =====

--- SpriteRendererのプロパティを定義
--- @class SpriteRendererPropertiesDefinition
--- @field _enabled? boolean
--- @field texturePath? string
--- @field color? {r: number, g: number, b: number, a:number} 0 to 1
--- @field origin? {x: number, y: number} 
--- @field crop? {x: number, y: number, w: number, h: number}
--- @field size? {w: number, h: number}
local SpriteRendererPropertiesDefinition = {}

--- RigidBodyのプロパティを定義
--- @class RigidBodyPropertiesDefinition
--- @field _enabled? boolean
--- @field mass? number
--- @field bodyType? love.BodyType
local RigidBodyPropertiesDefinition = {}

--- Collisionのプロパティを定義
--- @class CollisionPropertiesDefinition
--- @field _enabled? boolean
--- @field size? {x: number, y: number}
--- @field offset? {x: number, y: number}
--- @field isSensor? boolean
local CollisionPropertiesDefinition = {}
