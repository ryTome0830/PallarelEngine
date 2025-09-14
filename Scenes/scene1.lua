return {
    name = "Scene1",
    gameObjects = {
        {
            name = "GO1",
            properties = {
                position = {x = 3, y = 3},
                rotation = 0,
                scale = {x = 1, y = 1}
            },
            components = {
                {
                    componentType = "RigidBody",
                    properties = {0, 0, "static"}
                },
                {
                    components = "SpriteRenderer",
                    properties = {0, 0, "/Assets/Img/test.png"}
                }
            }
        }
    }
}