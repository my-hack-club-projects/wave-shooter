local oo = require 'libs.oo'

local Vector2 = require 'types.vector2'
local Entity = require 'classes.entity'

local Bullet = oo.class(Entity)

function Bullet:init(props)
    Entity.init(self, props)

    assert(props.direction, "Bullet needs a direction")

    self.name = "Bullet"
    self.size = Vector2(0.4, 0.4)
    self.damage = props.damage or 1
    self.randomness = props.randomness or 0

    local randomAngle = math.atan2(props.direction.y, props.direction.x) +
        (math.random() * 2 - 1) * math.rad(self.randomness)

    local randomDirection = Vector2(math.cos(randomAngle), math.sin(randomAngle))
    self.direction = randomDirection
    self.speed = props.speed or 10
    self.lifeDuration = props.lifeDuration or 10

    self.alive = true
end

function Bullet:update(dt)
    self.position = self.position + self.direction * self.speed * dt
    self.lifeDuration = self.lifeDuration - dt

    if self.lifeDuration <= 0 then
        self.alive = false
        self:destroy()
    end
end

function Bullet:checkCollision(characters)
    for _, character in ipairs(characters) do
        if self.game.physics.aabb(self.position, self.size, character.position, character.size) then
            character:takeDamage(self.damage)
            self.alive = false
            self:destroy()
        end
    end
end

return Bullet
