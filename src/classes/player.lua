local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local Vector2 = require 'types.vector2'

local Character = require 'classes.character'
local Bullet = require 'classes.bullet'

local Player = oo.class(Character)

function Player:init(props)
    Character.init(self, props)

    self.name = "Player"
end

function Player:getDirection()
    return Vector2(
        love.keyboard.isDown("d") and 1 or love.keyboard.isDown("a") and -1 or 0,
        love.keyboard.isDown("s") and 1 or love.keyboard.isDown("w") and -1 or 0
    )
end

function Player:fire()
    table.insert(
        self.bullets,
        self.game.current.entity.new(
            Bullet,
            {
                position = self.position,
                rotation = self.rotation,
                direction = self.mouseDirection,
                speed = 5,
                damage = 1
            }
        )
    )
end

return Player
