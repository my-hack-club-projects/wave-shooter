local oo = require 'libs.oo'
local tablef = require 'classes.tablef'
local State = require 'classes.state'
local Vector2 = require 'types.vector2'
local Color4 = require 'types.color4'
local UDim2 = require 'types.udim2'

local Camera = require 'classes.camera'
local Player = require 'classes.player'
local Enemy = require 'classes.enemy'
local Entity = require 'classes.entity'

local Boundary = require 'game.states.Play.classes.boundary'

local UpgradesUI = require 'game.states.Play.classes.upgradesui'
local ShotTypeUI = require 'game.states.Play.classes.shottypeui'
local TextUI = require 'game.states.Play.classes.textui'
local FadeUI = require 'game.states.Play.classes.fadeui'

local function getRandomPositionForEnemy(self)
    local randAngle = math.random() * math.pi * 2
    local randRadius = math.random() * self.enemySpawnRadius

    return Vector2(
        math.cos(randAngle) * randRadius,
        math.sin(randAngle) * randRadius
    )
end

local function getEnemyStrength(self)
    local wave = self.data.wave
    local min, max = wave * 0.5, wave * 1.5

    return math.random() * (max - min) + min
end

local PlayState = oo.class(State)

function PlayState:init(game)
    State.init(self, game)

    self.name = "PlayState"
    self.camera = Camera(self.game)

    self.mapRadius = 80
    self.enemySpawnRadius = self.mapRadius * 0.8
    self.enemySpawnInterval = 1
    self.waveFinishedSpawning = true
    self.intermissionDuration = 10

    self.enemies = {}

    self.upgradesUI = UpgradesUI(self.game)
    self.upgradesUI.visible = false

    self.shotTypeUI = ShotTypeUI(self.game)

    self.waveCounter = TextUI(self.game, {
        textFormat = "Wave: %d",
        position = UDim2(0.5, 0, 0.1, 0),
        size = UDim2(1, 0, 0, 20),
        font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 20),
    })

    self.scoreCounter = TextUI(self.game, {
        textFormat = "%d",
        position = UDim2(0.05, 0, 0.95, 0),
        anchorPoint = Vector2(0, 1),
        size = UDim2(1, 0, 0, 20),
        font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 20),
        textAlignX = "left",
    })
end

function PlayState:enter(prevState)
    State.enter(self, prevState)

    self.data = {
        score = 0,
        wave = 0,
    }

    self.floorImage = self.entity.new(
        Entity,
        {
            game = self.game,
            position = Vector2(0, 0),
            size = Vector2(self.mapRadius * 2, self.mapRadius * 2),
            color = Color4.fromHex("#005F73"),
            zindex = -1,
            image = love.graphics.newImage("assets/images/floor.png"),
        }
    )

    self.boundary = self.entity.new(
        Boundary,
        {
            position = Vector2(0, 0),
            radius = self.mapRadius,
            color = Color4(1, 1, 1, 1),
        }
    )

    self.player = self.entity.new(
        Player,
        {
            speed = 2,
            acceleration = 100,
            drag = 20,
            camera = self.camera,
        }
    )

    self.player.signals.died:once(function()
        self.game:setState("Deathscreen", { score = self.data.score, wave = self.data.wave })
    end)

    self.listeners = {
        self.game.signals.wheelmoved:connect(function(x, y)
            self.player:cycleShotType(y)
        end),

        self.boundary.entityExited:connect(function(entity)
            if entity == self.player then
                entity:takeDamage(love.timer.getDelta() * 50)
            elseif entity.name == "Bullet" then
                entity:destroy()
            elseif entity.name == "Enemy" then
                entity:takeDamage(entity.health)
            end
        end),
    }

    self:nextWave()

    self.fadeUI = FadeUI(self.game)
    self.fadeUI:fadeOut(1)

    self.game:defer(1.5, function()
        self.fadeUI.visible = false
    end)

    self.music = self.game.sound:play("music" .. math.random(1, 3), 0.4)
    self.music:setLooping(true)
end

function PlayState:exit()
    State.exit(self)

    for _, listener in ipairs(self.listeners) do
        listener:disconnect()
    end

    self.music:stop()
end

function PlayState:spawnEnemy()
    local enemy = self.entity.new(
        Enemy,
        {
            position = getRandomPositionForEnemy(self),
            target = self.player,
            strength = getEnemyStrength(self),
        }
    )

    enemy.signals.died:once(function()
        self.data.score = self.data.score + 1
        print("Score is now " .. self.data.score)
        self.scoreCounter:setValue(self.data.score)

        local me = tablef.find(self.enemies, function(e) return e.enemy == enemy end)
        table.remove(self.enemies, me)

        if #self.enemies == 0 then
            self:intermission()
        end
    end)

    table.insert(self.enemies, {
        enemy = enemy,
    })
end

function PlayState:intermission()
    if not self.waveFinishedSpawning then
        return
    end

    -- Show upgrades UI
    local randomUpgrades = self.player:getRandomUpgrades(3)

    self.upgradesUI:chooseUpgrade({
        upgrades = randomUpgrades,
        maxTier = self.player.maxUpgradeTier,
    }, function(upgrade)
        self.player:upgrade(upgrade.name)

        self.upgradesUI:cancelChoosingUpgrade()
    end)

    self.game:defer(self.intermissionDuration, function()
        self.upgradesUI:cancelChoosingUpgrade()

        self:nextWave()
    end)
end

function PlayState:nextWave()
    tablef.clear(self.enemies)

    self.data.wave = self.data.wave + 1
    self.waveFinishedSpawning = false

    print("Wave " .. self.data.wave .. " started")
    self.waveCounter:setValue(self.data.wave)

    for i = 1, self.data.wave do
        self.game:defer(self.enemySpawnInterval * i, function()
            self:spawnEnemy()

            if i == self.data.wave then
                self.waveFinishedSpawning = true
            end
        end)
    end
end

function PlayState:draw()
    State.draw(self)

    self.upgradesUI:draw()
    self.shotTypeUI:draw()
    self.waveCounter:draw()
    self.scoreCounter:draw()

    self.fadeUI:draw()
end

function PlayState:update(dt)
    State.update(self, dt)

    self.upgradesUI:update()
    self.shotTypeUI:update()
    self.waveCounter:update()
    self.scoreCounter:update()
    self.fadeUI:update(dt)
end

return PlayState
