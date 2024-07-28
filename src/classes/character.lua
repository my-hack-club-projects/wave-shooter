local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local Vector2 = require 'types.vector2'
local Signal = require 'libs.signal'

local Entity = require 'classes.entity'
local Character = oo.class(Entity)

Character.InaccurateRange = 90

function Character:init(props)
    assert(props.game, "Character needs a game")

    Entity.init(self, props)

    self.size = Vector2(1, 1)

    self.name = "Character"
    self.health = props.health or 100
    self.speed = props.speed or 1
    self.acceleration = props.acceleration or 1
    self.drag = props.drag or 1
    self.velocity = Vector2()
    self.mouseDirection = Vector2()

    self.lastFired = 0
    self.fireRate = props.fireRate or 10
    self.accuracy = props.accuracy or 0.9
    self.damage = props.damage or 1
    self.bulletSpeed = props.bulletSpeed or 10
    self.bulletLifeDuration = props.bulletLifeDuration or 10
    self.bulletCount = props.bulletCount or 1

    self.bullets = {}

    self.signals = {
        died = Signal(),
    }
end

function Character:takeDamage(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self.signals.died:dispatch()
        self:destroy()
    end
end

function Character:getDirection()
    error("Subclasses must implement this method")
end

function Character:fire()
    error("Subclasses must implement this method")
end

function Character:update(dt)
    -- Get direction of keyboard input
    local direction = self:getDirection()
    assert(
        direction and direction.x and direction.y and direction.magnitude and direction.unit,
        "Character:getDirection() must return a Vector2"
    )

    if direction.magnitude > 0 then -- Normalize it, so it's not faster diagonally
        direction = direction.unit
    end

    -- Add the direction to velocity
    self.velocity = self.velocity + direction * self.acceleration * dt

    -- And subtract drag
    local velocityDirection, velocityMagnitude = self.velocity.unit, self.velocity.magnitude
    if velocityMagnitude > 0 then
        velocityMagnitude = mathf.clamp(mathf.approach(velocityMagnitude, 0, self.drag * dt), -self.speed, self.speed)
        self.velocity = velocityDirection * velocityMagnitude
    end

    -- Add the velocity to the player position
    self.position = self.position + self.velocity * self.speed * dt

    for i, bullet in ipairs(self.bullets) do
        bullet:update(dt)
        if bullet.dead then
            table.remove(self.bullets, i)
        end
    end
end

return Character
