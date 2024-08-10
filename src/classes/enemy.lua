local oo = require 'libs.oo'
local tablef = require 'classes.tablef'
local Vector2 = require 'types.vector2'
local Character = require 'classes.character'
local Bullet = require 'classes.bullet'

local Enemy = oo.class(Character)
Enemy.MaxStrength = 20
Enemy.Presets = {
    function(self)
        -- Large, slow, big damage
        local strength = self.strength
        local strengthRatio = math.min(strength / self.MaxStrength, 1)
        local shotType = self.shotTypes[1]

        self.image = love.graphics.newImage("assets/images/enemy1.png")

        self.size = Vector2(1 + strengthRatio * 10, 1 + strengthRatio * 10)
        self.speed = 2 - strengthRatio * 1
        self.maxHealth = 10 + strengthRatio * 1000
        self.health = self.maxHealth
        self.healSpeed = self.maxHealth / (10 - strengthRatio * 5)

        shotType.size = self.size / 3
        shotType.damage = 15 + strengthRatio * 45
        shotType.speed = 10 - strengthRatio * 6
        shotType.firerate = 3 - strengthRatio * 2.4
        shotType.accuracy = 0.8 + strengthRatio * 0.2
        shotType.lifeDuration = 5 + strengthRatio * 20
    end,

    function(self)
        -- Small, fast, high firerate, low damage

        local strength = self.strength
        local strengthRatio = math.min(strength / self.MaxStrength, 1)
        local shotType = self.shotTypes[1]

        self.image = love.graphics.newImage("assets/images/enemy2.png")

        self.size = Vector2(1 + strengthRatio, 1 + strengthRatio)
        self.speed = 2 + strengthRatio * 2
        self.maxHealth = 10 + strengthRatio * 100
        self.health = self.maxHealth
        self.healSpeed = self.maxHealth / (10 - strengthRatio * 5)

        shotType.size = self.size / 5
        shotType.damage = 5 + strengthRatio * 4
        shotType.speed = 10 + strengthRatio * 15
        shotType.firerate = 0.5 + strengthRatio * 25
        shotType.accuracy = 0.7 + strengthRatio * 0.2
        shotType.lifeDuration = 2 + strengthRatio * 2
    end,

    function(self)
        -- Has a shotgun, firerate & damage gets higher

        local strength = self.strength
        local strengthRatio = math.min(strength / self.MaxStrength, 1)
        local shotType = self.shotTypes[1]

        self.size = Vector2(1 + strengthRatio * 2, 1 + strengthRatio * 2)
        self.speed = 1.5 + strengthRatio * 0.5
        self.maxHealth = 10 + strengthRatio * 200
        self.health = self.maxHealth
        self.healSpeed = self.maxHealth / (10 - strengthRatio * 5)

        shotType.size = self.size / 3
        shotType.damage = 5 + strengthRatio * 10
        shotType.speed = 20 - strengthRatio * 7
        shotType.firerate = 0.5 + strengthRatio * 2
        shotType.accuracy = 0.8 + strengthRatio * 0.2
        shotType.lifeDuration = 2 + strengthRatio * 2
        shotType.bulletCount = math.floor(5 + strengthRatio * 15)
        shotType.spreadAngle = math.rad(6 - strengthRatio)
    end,
}

function Enemy:init(props)
    Character.init(self, props)

    self.name = "Enemy"
    self.size = props.size or Vector2(1, 1)
    self.strength = props.strength or 1
    self.speed = props.speed or 1
    self.acceleration = 100

    self.targets = props.targets or { self.game.current.entity.find("Player") }
    self.targetDirection = Vector2()
    self.target = self.targets[1]

    self.shotTypes = {
        {
            name = "Default",
            damage = 1,
            speed = 1,
            firerate = 1,
            accuracy = 1,
            lifeDuration = 1,
            bulletCount = 1,
        }
    }

    self.Presets[math.random(1, #self.Presets)](self)

    self:chooseShotType("Default")
end

function Enemy:getTarget()
    -- return the closest target from self.targets

    local closestTarget = self.targets[1]
    local closestDistance = (closestTarget.position - self.position).magnitude

    for _, target in ipairs(self.targets) do
        local distance = (target.position - self.position).magnitude
        if distance < closestDistance then
            closestTarget = target
            closestDistance = distance
        end
    end

    return closestTarget
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

function Enemy:update(dt)
    Character.update(self, dt)

    for _, bullet in ipairs(self.bullets) do
        bullet:checkCollision(self.targets)
    end

    self:fire()
end

function Enemy:fire()
    if love.timer.getTime() - self.lastFired > 1 / self.fireRate then
        self.lastFired = love.timer.getTime()

        Character.fire(self)
    end
end

return Enemy
