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

    self.direction = props.direction
    self.speed = props.speed or 10
    self.lifeDuration = props.lifeDuration or 10
end

function Bullet:update(dt)
    self.position = self.position + self.direction * self.speed * dt
    self.lifeDuration = self.lifeDuration - dt

    if self.lifeDuration <= 0 then
        self:destroy()
    end
end

return Bullet
