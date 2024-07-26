local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local Vector2 = require 'types.vector2'

local Entity = require 'classes.entity'
local Player = oo.class(Entity)

function Player:init(props)
    Entity.init(self, props)

    self.size = Vector2(1, 1)

    self.name = "Player"
    self.speed = props.speed or 1
    self.acceleration = props.acceleration or 1
    self.drag = props.drag or 1
    self.velocity = Vector2()
end

function Player:update(dt)
    local direction = Vector2(
        (love.keyboard.isDown("a") and -1 or 0) + (love.keyboard.isDown("d") and 1 or 0),
        (love.keyboard.isDown("w") and -1 or 0) + (love.keyboard.isDown("s") and 1 or 0)
    ) * self.acceleration

    if direction.magnitude > 0 then
        direction = direction.unit
    end

    self.velocity = self.velocity + direction * self.acceleration * dt

    local velocityDirection, velocityMagnitude = self.velocity.unit, self.velocity.magnitude
    if velocityMagnitude > 0 then
        velocityMagnitude = mathf.approach(velocityMagnitude, 0, self.drag * dt)
        self.velocity = velocityDirection * velocityMagnitude
    end

    self.velocity.x = mathf.clamp(self.velocity.x, -self.speed, self.speed)
    self.velocity.y = mathf.clamp(self.velocity.y, -self.speed, self.speed)

    self.position = self.position + self.velocity * self.speed * dt
end

return Player
