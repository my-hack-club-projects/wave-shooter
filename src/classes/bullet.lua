local oo = require 'libs.oo'

local Vector2 = require 'types.vector2'
local Entity = require 'classes.entity'

local Bullet = oo.class(Entity)

function Bullet:init(props)
    Entity.init(self, props)

    assert(props.direction, "Bullet needs a direction")

    self.name = "Bullet"
    self.firedBy = props.firedBy
    self.size = props.size or Vector2(0.4, 0.4)
    self.damage = props.damage or 1
    self.penetration = props.penetration or 0
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
    if not self.alive then
        return
    end

    self.position = self.position + self.direction * self.speed * dt
    self.lifeDuration = self.lifeDuration - dt

    if self.lifeDuration <= 0 then
        self.alive = false
        self:destroy()
    end
end

function Bullet:checkCollision(characters)
    if not self.alive then
        return
    end

    for _, character in ipairs(characters) do
        if self.game.physics.aabb(self.position, self.size, character.position, character.size) then
            character:takeDamage(self.damage)
            self.alive = false
            self:destroy()

            self.game.sound:play("hitmarker", 0.2)
        end
    end

    -- find other bullets
    local function radiusCollision(pos1, radius1, pos2, radius2)
        return (pos1 - pos2).magnitude < radius1 + radius2
    end

    local bullets = self.game.current.entity.findAll("Bullet")

    for _, bullet in ipairs(bullets) do
        if bullet.firedBy ~= self.firedBy and self.penetration >= bullet.penetration and radiusCollision(self.position, self.size.x, bullet.position, bullet.size.x) then
            self.game.sound:play("hitmarker", 0.2)

            bullet.alive = false
            bullet:destroy()

            self.penetration = self.penetration - bullet.penetration

            if self.penetration < 0 then
                self.alive = false
                self:destroy()
            end
        end
    end
end

return Bullet
