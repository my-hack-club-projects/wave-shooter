local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local tablef = require 'classes.tablef'
local Vector2 = require 'types.vector2'

local Character = require 'classes.character'
local Bullet = require 'classes.bullet'

local Player = oo.class(Character)

function Player:init(props)
    Character.init(self, props)

    assert(props.camera, "Player requires a camera")

    self.name = "Player"
    self.camera = props.camera

    self.autoAimMagnitude = props.autoAimMagnitude or 1

    self:chooseShotType("Default")
end

function Player:getDirection()
    return Vector2(
        love.keyboard.isDown("d") and 1 or love.keyboard.isDown("a") and -1 or 0,
        love.keyboard.isDown("s") and 1 or love.keyboard.isDown("w") and -1 or 0
    )
end

function Player:fire()
    -- Implement bullet count - how many bullets at once. When 1, fire straight ahead, when more, spread them out
    -- table.insert(
    --     self.bullets,
    --     self.game.current.entity.new(
    --         Bullet,
    --         {
    --             position = self.position,
    --             rotation = self.rotation,
    --             direction = self.aimDirection,
    --             randomness = ((1 - self.accuracy) * self.InaccurateRange),
    --             speed = self.bulletSpeed,
    --             damage = self.damage,
    --             lifeDuration = self.bulletLifeDuration,
    --         }
    --     )
    -- )

    for i = 1, self.bulletCount do
        local angle = self.rotation + (i - 1 - self.bulletCount / 2) * (self.bulletCount > 1 and self.spreadAngle or 0)
        local direction = Vector2(math.cos(angle), math.sin(angle))

        table.insert(
            self.bullets,
            self.game.current.entity.new(
                Bullet,
                {
                    position = self.position,
                    rotation = angle,
                    direction = direction,
                    randomness = ((1 - self.accuracy) * self.InaccurateRange),
                    speed = self.bulletSpeed,
                    damage = self.damage,
                    lifeDuration = self.bulletLifeDuration,
                }
            )
        )
    end
end

function Player:updateCamera()
    -- TODO: Move the camera to the player smoothly
end

function Player:update(dt)
    Character.update(self, dt)

    local mouseWorldPosition = Vector2(self.camera:screenToWorld(love.mouse.getPosition()))

    -- Aim (aim assist / locking)
    local allEnemies = self.game.current.entity.findAll("Enemy")
    local closest, closestDistance = nil, math.huge
    for _, enemy in ipairs(allEnemies) do
        local distance = (enemy.position - mouseWorldPosition).magnitude - enemy.size.magnitude / 2

        if distance < self.autoAimMagnitude and distance < closestDistance then
            closest = enemy
            closestDistance = distance
        end
    end

    if closest then
        mouseWorldPosition = closest.position
    end

    self.aimDirection = (mouseWorldPosition - self.position).unit
    self.rotation = math.atan2(self.aimDirection.y, self.aimDirection.x)

    -- Fire
    if love.mouse.isDown(1) and love.timer.getTime() - self.lastFired > 1 / self.fireRate then
        self.lastFired = love.timer.getTime()
        self:fire()
    end

    for _, bullet in ipairs(self.bullets) do
        if not bullet.alive then
            table.remove(self.bullets, tablef.find(self.bullets, function(b) return b == bullet end))
        end

        bullet:checkCollision(allEnemies)
    end

    self:updateCamera()
end

return Player
