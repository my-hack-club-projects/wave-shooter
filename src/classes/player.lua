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

    self.shotTypes = {}

    self.upgrades = {
        sniper = {
            name = "Sniper",
            description = "A strong and accurate shot with long range!",
            tier = 0,

            apply = function()
                local upgrade = self.upgrades.sniper
                local existing = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
                    return shotType.name == "sniper"
                end)]

                if not existing then
                    existing = {
                        name = "sniper"
                    }

                    table.insert(self.shotTypes, existing)
                end

                existing.damage = 100 + 50 * upgrade.tier
                existing.speed = 20 + 5 * upgrade.tier
                existing.firerate = 0.4 + 0.3 * upgrade.tier
                existing.accuracy = 1
                existing.lifeDuration = 20
                existing.bulletCount = 1
            end,
        },

        shotgun = {
            name = "Shotgun",
            description = "A spread of bullets that can hit multiple enemies!",
            tier = 0,

            apply = function()
                local upgrade = self.upgrades.shotgun
                local existing = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
                    return shotType.name == "shotgun"
                end)]

                if not existing then
                    existing = {
                        name = "shotgun"
                    }

                    table.insert(self.shotTypes, existing)
                end

                existing.damage = 10 + 5 * upgrade.tier
                existing.speed = 10 + 2.5 * upgrade.tier
                existing.firerate = 0.8 + 0.4 * upgrade.tier
                existing.accuracy = 0.7
                existing.lifeDuration = 10
                existing.bulletCount = 5
            end,
        },

        machineGun = {
            name = "Machine Gun",
            description = "A rapid fire of bullets that can suppress enemies!",
            tier = 0,

            apply = function()
                local upgrade = self.upgrades.machineGun
                local existing = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
                    return shotType.name == "machineGun"
                end)]

                if not existing then
                    existing = {
                        name = "machineGun"
                    }

                    table.insert(self.shotTypes, existing)
                end

                existing.damage = 1 + 0.5 * upgrade.tier
                existing.speed = 10 + 2.5 * upgrade.tier
                existing.firerate = 20 + 10 * upgrade.tier
                existing.accuracy = 0.8 + 0.05 * upgrade.tier
                existing.lifeDuration = 5
                existing.bulletCount = 1
            end,
        },
    }
end

function Player:chooseShotType(shotTypeName)
    local shotType = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
        return shotType.name == shotTypeName
    end)]

    if not shotType then
        return
    end

    self.damage = shotType.damage
    self.bulletSpeed = shotType.speed
    self.fireRate = shotType.firerate
    self.accuracy = mathf.clamp(shotType.accuracy, 0, 1)
    self.bulletLifeDuration = shotType.lifeDuration
    self.bulletCount = shotType.bulletCount
end

function Player:upgrade(upgradeName)
    local upgrade = self.upgrades[upgradeName]

    if not upgrade then
        return
    end

    upgrade.tier = upgrade.tier + 1
    upgrade.apply()
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
                direction = self.aimDirection,
                randomness = ((1 - self.accuracy) * self.InaccurateRange),
                speed = self.bulletSpeed,
                damage = self.damage,
            }
        )
    )
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
        bullet:checkCollision(allEnemies)
    end

    self:updateCamera()
end

return Player
