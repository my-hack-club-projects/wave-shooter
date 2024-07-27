local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local Vector2 = require 'types.vector2'

local Entity = require 'classes.entity'
local Character = oo.class(Entity)

function Character:init(props)
    assert(props.camera, "Character needs a camera")
    assert(props.game, "Character needs a game")

    self.camera = props.camera

    Entity.init(self, props)

    self.size = Vector2(1, 1)

    self.name = "Character"
    self.speed = props.speed or 1
    self.acceleration = props.acceleration or 1
    self.drag = props.drag or 1
    self.velocity = Vector2()
    self.mouseDirection = Vector2()

    self.lastFired = 0
    self.fireRate = props.fireRate or 10
    self.bullets = {}
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
        velocityMagnitude = mathf.approach(velocityMagnitude, 0, self.drag * dt)
        self.velocity = velocityDirection * velocityMagnitude
    end

    -- Clamp the velocity to self.speed
    self.velocity.x = mathf.clamp(self.velocity.x, -self.speed, self.speed)
    self.velocity.y = mathf.clamp(self.velocity.y, -self.speed, self.speed)

    -- Add the velocity to the player position
    self.position = self.position + self.velocity * self.speed * dt

    -- Move the camera so that the player is in the center
    self.camera.position = self.position

    -- Get mouse position in the real world
    local mouseX, mouseY = love.mouse.getPosition()
    local playerPositionPx = (self.position - self.camera.position) * self.camera:getUnitSize() +
        Vector2(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    -- Get the angle between the player and the mouse
    self.mouseDirection = (Vector2(mouseX, mouseY) - playerPositionPx).unit
    local angle = math.atan2(self.mouseDirection.y, self.mouseDirection.x)
    self.rotation = angle

    -- Fire
    if love.mouse.isDown(1) and love.timer.getTime() - self.lastFired > 1 / self.fireRate then
        self.lastFired = love.timer.getTime()
        self:fire()
    end
end

return Character
