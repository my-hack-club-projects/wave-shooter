local oo = require 'libs.oo'
local import = require 'classes.import'
local mathf = require 'classes.mathf'
local tablef = require 'classes.tablef'
local Vector2 = require 'types.vector2'
local UDim2 = require 'types.udim2'
local Color4 = require 'types.color4'
local Signal = require 'libs.signal'

local WorldUI, Frame = import({ 'WorldUI', 'Frame' }, 'classes.ui')

local Entity = require 'classes.entity'
local Bullet = require 'classes.bullet'
local Character = oo.class(Entity)

Character.InaccurateRange = 90

Character.Upgrades = {
    sniper = {
        name = "Sniper",
        description = "A strong and accurate shot with long range!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.sniper
            local existing = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
                return shotType.name == "Sniper"
            end)]

            if not existing then
                existing = {
                    name = "Sniper"
                }

                table.insert(self.shotTypes, existing)
            end

            existing.damage = 50 + 60 * upgrade.tier
            existing.speed = 20 + 5 * upgrade.tier
            existing.firerate = 0.4 + 0.3 * upgrade.tier
            existing.accuracy = 1
            existing.lifeDuration = 20
            existing.bulletCount = 1
            existing.size = Vector2(1.5, 0.2)
            existing.penetration = 2 + upgrade.tier * 3
            existing.image = love.graphics.newImage("assets/images/bullet1.png")
            existing.sound = "sniper"

            self:chooseShotType(existing)
        end,
    },

    shotgun = {
        name = "Shotgun",
        description = "A spread of bullets that can hit multiple enemies!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.shotgun
            local existing = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
                return shotType.name == "Shotgun"
            end)]

            if not existing then
                existing = {
                    name = "Shotgun"
                }

                table.insert(self.shotTypes, existing)
            end

            existing.damage = 10 + 5 * upgrade.tier
            existing.speed = 10 + 2.5 * upgrade.tier
            existing.firerate = 0.8 + 0.4 * upgrade.tier
            existing.accuracy = 0.7
            existing.lifeDuration = 0.8 + 0.3 * upgrade.tier
            existing.bulletCount = 5 + 2 * upgrade.tier
            existing.spreadAngle = math.rad(5)
            existing.size = Vector2(0.3, 0.3)
            existing.penetration = 1 + math.floor(upgrade.tier / 2)
            existing.image = love.graphics.newImage("assets/images/bullet3.png")
            existing.sound = "shotgun"

            self:chooseShotType(existing)
        end,
    },

    machineGun = {
        name = "Machine Gun",
        description = "A rapid fire of bullets that can suppress enemies!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.machineGun
            local existing = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
                return shotType.name == "Machine Gun"
            end)]

            if not existing then
                existing = {
                    name = "Machine Gun"
                }

                table.insert(self.shotTypes, existing)
            end

            existing.damage = 12 + 10 * upgrade.tier
            existing.speed = 10 + 2.5 * upgrade.tier
            existing.firerate = 6 + 1 * upgrade.tier
            existing.accuracy = 0.85 + 0.03 * upgrade.tier
            existing.lifeDuration = 5
            existing.bulletCount = 1
            existing.size = Vector2(0.4, 0.25)
            existing.penetration = 1
            existing.image = love.graphics.newImage("assets/images/bullet1.png")
            existing.sound = "machine_gun"

            self:chooseShotType(existing)
        end,
    },

    cannon = {
        name = "Cannon",
        description = "A powerful shot that can penetrate bullets!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.cannon
            local existing = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
                return shotType.name == "Cannon"
            end)]

            if not existing then
                existing = {
                    name = "Cannon"
                }

                table.insert(self.shotTypes, existing)
            end

            existing.damage = 35 + 50 * upgrade.tier
            existing.speed = 10 - 1 * upgrade.tier
            existing.firerate = 0.4 - 0.07 * upgrade.tier
            existing.accuracy = 1
            existing.lifeDuration = 10
            existing.bulletCount = 1
            existing.size = Vector2(1, 1) * (0.5 + 0.8 * upgrade.tier)
            existing.penetration = 10 + 10 * upgrade.tier
            existing.image = love.graphics.newImage("assets/images/bullet2.png")
            existing.sound = "cannon"

            self:chooseShotType(existing)
        end,
    },

    regeneration = {
        name = "Regeneration",
        description = "Heal more over time!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.regeneration

            self.healSpeed = 1 + 3 * upgrade.tier
        end,
    },

    speed = {
        name = "Speed",
        description = "Move faster!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.speed

            self.speed = 2 + 1 * upgrade.tier
        end,
    },

    health = {
        name = "Health",
        description = "More health!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.health

            self.maxHealth = 100 + 100 * upgrade.tier
            self.health = self.maxHealth
        end,
    },

    recoilReduction = {
        name = "Recoil Reduction",
        description = "Less recoil!",
        tier = 0,

        apply = function(self)
            local upgrade = self.Upgrades.recoilReduction

            self.recoilModifier = 1 - 0.1 * upgrade.tier
        end,
    },
}

Character.MaxUpgradeTier = 5

function Character:init(props)
    assert(props.game, "Character needs a game")

    Entity.init(self, props)

    self.size = Vector2(1, 1)

    self.name = "Character"

    self.health = props.health or 100
    self.maxHealth = props.maxHealth or 100
    self.healSpeed = 1

    self.speed = props.speed or 1
    self.acceleration = props.acceleration or 1
    self.drag = props.drag or 1
    self.velocity = Vector2()
    self.velocityOffset = Vector2()
    self.velocityOffsetDecay = 15
    self.mouseDirection = Vector2()

    self.lastFired = 0
    self.fireRate = props.fireRate or 10
    self.accuracy = props.accuracy or 0.9
    self.damage = props.damage or 1
    self.bulletSpeed = props.bulletSpeed or 10
    self.bulletLifeDuration = props.bulletLifeDuration or 10
    self.bulletCount = props.bulletCount or 1
    self.bulletSize = props.bulletSize or Vector2(0.4, 0.4)
    self.recoilModifier = props.recoilModifier or 1

    self.bullets = {}

    self.shotTypes = {
        {
            name = "Default",
            damage = 10,
            speed = 10,
            firerate = 5,
            accuracy = 0.85,
            lifeDuration = 1,
            bulletCount = 1,
            size = Vector2(0.4, 0.4),
            penetration = 1,
            selected = true,
            image = love.graphics.newImage("assets/images/bullet1.png"),
            sound = "default_gun",
        },
    }

    self.Upgrades = tablef.copy(Character.Upgrades)

    self.signals = {
        died = Signal(),
    }

    self.healthbarUI = WorldUI(self.game)
    self.healthbarUI.size = Vector2(3, 0.4)
    self.healthbarUI.position = Vector2(0, 0)

    local frame = self.healthbarUI:addChild(Frame)
    frame.size = UDim2(1, 0, 1, 0)
    frame.position = UDim2(0, 0, 0, 0)
    frame.anchorPoint = Vector2(0, 0)
    frame.color = Color4.fromHex("#001219")

    local container = frame:addChild(Frame)
    container.size = UDim2(1, -6, 1, -6)
    container.position = UDim2(0.5, 0, 0.5, 0)
    container.anchorPoint = Vector2(0.5, 0.5)
    container.color = Color4(0, 0, 0, 0)

    self.healthbar = container:addChild(Frame)
    self.healthbar.size = UDim2(1, 0, 1, 0)
    self.healthbar.position = UDim2(0, 0, 0.5, 0)
    self.healthbar.anchorPoint = Vector2(0, 0.5)
    self.healthbar.color = Color4.fromHex("#AE2012")
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
    local rotation = self.rotation
    local direction = Vector2(math.cos(rotation), math.sin(rotation))
    local frontFacePosition = self.position + direction * self.size.y / 2

    local totalRecoil = 0
    for i = 1, self.bulletCount do
        local angle = self.rotation + (i - 1 - self.bulletCount / 2) * (self.bulletCount > 1 and self.spreadAngle or 0)
        local direction = Vector2(math.cos(angle), math.sin(angle))

        table.insert(
            self.bullets,
            self.game.current.entity.new(
                Bullet,
                {
                    firedBy = self,
                    position = frontFacePosition,
                    rotation = angle,
                    size = self.bulletSize,
                    direction = direction,
                    randomness = ((1 - self.accuracy) * self.InaccurateRange),
                    speed = self.bulletSpeed,
                    damage = self.damage,
                    lifeDuration = self.bulletLifeDuration,
                    penetration = self.penetration,
                    image = self.bulletImage,
                }
            )
        )

        totalRecoil = totalRecoil + self.bulletSize.magnitude * self.bulletSpeed * self.recoilModifier
    end

    self.velocityOffset = self.velocityOffset - direction * totalRecoil
end

function Character:chooseShotType(shotTypeName)
    for _, v in pairs(self.shotTypes) do
        v.selected = false
    end

    local shotType = shotTypeName
    if type(shotTypeName) == "string" then
        shotType = self.shotTypes[tablef.find(self.shotTypes, function(shotType)
            return shotType.name == shotTypeName
        end)]

        if not shotType then
            return
        end
    end

    shotType.selected = true

    self.damage = shotType.damage
    self.bulletSpeed = shotType.speed
    self.fireRate = shotType.firerate
    self.accuracy = mathf.clamp(shotType.accuracy, 0, 1)
    self.bulletLifeDuration = shotType.lifeDuration
    self.bulletCount = shotType.bulletCount
    self.bulletSize = shotType.size or self.bulletSize
    self.spreadAngle = shotType.spreadAngle
    self.penetration = shotType.penetration
    self.bulletImage = shotType.image
    self.bulletSound = shotType.sound

    return shotType
end

function Character:cycleShotType(n)
    local currentIndex = tablef.find(self.shotTypes, function(shotType)
        return shotType.selected
    end) or 1

    local newIndex = (currentIndex + n - 1) % #self.shotTypes + 1

    local new = self:chooseShotType(self.shotTypes[newIndex].name)

    if new ~= self.shotTypes[currentIndex] then
        self.game.sound:play("equip")
    end
end

function Character:getRandomUpgrades(nUpgrades)
    local upgrades = {}

    for i = 1, nUpgrades do
        local availableUpgrades = {}
        for _, upgrade in pairs(self.Upgrades) do
            if upgrade.tier < self.MaxUpgradeTier and not tablef.find(upgrades, function(u)
                    return u.name == upgrade
                        .name
                end) then
                table.insert(availableUpgrades, upgrade)
            end
        end

        if #availableUpgrades == 0 then
            break
        end

        local upgrade = availableUpgrades[math.random(1, #availableUpgrades)]

        table.insert(upgrades, upgrade)
    end

    return upgrades
end

function Character:upgrade(upgradeName)
    local upgrade = self.Upgrades[tablef.find(self.Upgrades, function(u) return u.name == upgradeName end)]

    if not upgrade then
        return
    end

    local nShotTypes = #self.shotTypes

    upgrade.tier = upgrade.tier + 1
    upgrade.apply(self)
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

    self.velocityOffset = self.velocityOffset *
        mathf.clamp(1 - self.velocityOffsetDecay * (self.size.magnitude / 2) * dt, 0, 1)

    -- Add the velocity to the player position
    self.position = self.position + self.velocity * self.speed * dt + self.velocityOffset * dt

    for i, bullet in ipairs(self.bullets) do
        bullet:update(dt)
        if not bullet.alive then
            table.remove(self.bullets, i)
        end
    end

    -- Heal
    if self.health < self.maxHealth then
        self.health = self.health + math.min(self.healSpeed * dt, self.maxHealth - self.health)
    end

    -- Update the healthbar
    self.healthbarUI.position = Vector2(
        self.position.x - self.healthbarUI.size.x / 2,
        self.position.y - self.size.y / 2 - 1
    )
    self.healthbar.size = UDim2(mathf.clamp(self.health / self.maxHealth, 0, 1), 0, 1, 0)

    self.healthbarUI:update(dt)
end

function Character:draw()
    Entity.draw(self)

    self.healthbarUI:draw()
end

return Character
