local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local Vector2 = require 'types.vector2'

local Character = require 'classes.character'
local Bullet = require 'classes.bullet'

local Player = oo.class(Character)

function Player:init(props)
    Character.init(self, props)

    assert(props.camera, "Player requires a camera")

    self.name = "Player"
    self.camera = props.camera
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
                speed = 10,
                damage = 1
            }
        )
    )
end

function Player:updateCamera()
    -- TODO: Move the camera to the player smoothly
end

function Player:update(dt)
    Character.update(self, dt)

    -- Get mouse position in the real world
    local mouseX, mouseY = love.mouse.getPosition()
    local playerPositionPx = (self.position - self.camera.position) * self.camera:getUnitSize() +
        Vector2(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    -- Get the angle between the player and the mouse
    self.mouseDirection = (Vector2(mouseX, mouseY) - playerPositionPx).unit
    local angle = math.atan2(self.mouseDirection.y, self.mouseDirection.x)
    self.rotation = angle

    self:updateCamera()

    -- Fire
    if love.mouse.isDown(1) and love.timer.getTime() - self.lastFired > 1 / self.fireRate then
        self.lastFired = love.timer.getTime()
        self:fire()
    end
end

return Player
