return {
    name = "Scene1",
    gameObjects = {
        {
            name = "GO1",
            components = {
                {
                    componentType = "PlayerController",
                    properties = {
                        speed = 5,
                        _enabled = true,
                        jumpHeight = 10
                    }
                }
            },
            properties = {
                transform = {
                    position = {
                        x = 3,
                        y = 3
                    },
                    rotation = 0,
                    scale = {
                        x = 1,
                        y = 1
                    }
                },
                enabled = true
            }
        }
    }
}