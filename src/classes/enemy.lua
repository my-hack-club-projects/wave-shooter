local oo = require 'libs.oo'

local Vector2 = require 'types.vector2'
local Character = require 'classes.character'
local Bullet = require 'classes.bullet'

local Enemy = oo.class(Character)

function Enemy:init(props)
    Character.init(self, props)

    self.name = "Enemy"
    self.size = props.size or Vector2(1, 1)
    self.speed = 1.5
    self.acceleration = 100

    self.target = props.target or self.game.current.entity.find("Player")
    self.targetDirection = Vector2()
end

function Enemy:getDirection()
    local magnitude = (self.target.position - self.position).magnitude

    if magnitude == 0 then
        return Vector2(0, 0)
    end

    local targetDirection = (self.target.position - self.position)
    self.targetDirection = Vector2(
        targetDirection.x / magnitude,
        targetDirection.y / magnitude
    )
    self.rotation = math.atan2(self.targetDirection.y, self.targetDirection.x)

    return self.targetDirection
end

function Enemy:fire()
    -- table.insert(
    --     self.bullets,
    --     self.game.current.entity.new(
    --         Bullet,
    --         {
    --             position = self.position,
    --             rotation = self.rotation,
    --             direction = self.targetDirection,
    --             speed = 10,
    --             damage = 1
    --         }
    --     )
    -- )
end

return Enemy