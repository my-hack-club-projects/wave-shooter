local oo = require 'libs.oo'
local tablef = require 'classes.tablef'
local State = require 'classes.state'
local Vector2 = require 'types.vector2'

local Camera = require 'classes.camera'
local Player = require 'classes.player'
local Enemy = require 'classes.enemy'

local UpgradesUI = require 'game.states.Play.classes.upgradesui'
local ShotTypeUI = require 'game.states.Play.classes.shottypeui'

local function getRandomPositionForEnemy(self)
    local randAngle = math.random() * math.pi * 2
    local randRadius = self.enemySpawnRadius + math.random() * (self.enemySpawnRadius - self.mapRadius)

    return Vector2(
        math.cos(randAngle) * randRadius,
        math.sin(randAngle) * randRadius
    )
end

local PlayState = oo.class(State)

function PlayState:init(game)
    State.init(self, game)

    self.data = {
        wave = 0,
        score = 0,
    }

    self.name = "PlayState"
    self.camera = Camera(self.game)

    self.mapRadius = 100
    self.enemySpawnRadius = 50
    self.enemySpawnInterval = 1
    self.waveFinishedSpawning = true
    self.intermissionDuration = 10

    self.enemies = {}

    self.upgradesUI = UpgradesUI(self.game)
    self.upgradesUI.visible = false

    self.shotTypeUI = ShotTypeUI(self.game)
end

function PlayState:enter(prevState)
    State.enter(self, prevState)

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
        self.game:changeState("GameOverState", self.data)
    end)

    self:nextWave()
end

function PlayState:spawnEnemy()
    local enemy = self.entity.new(
        Enemy,
        {
            position = getRandomPositionForEnemy(self),
            target = self.player
        }
    )

    enemy.signals.died:once(function()
        self.data.score = self.data.score + 1
        print("Score is now " .. self.data.score)

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
    -- Show upgrades UI
    local randomUpgrades = self.player:getRandomUpgrades(3)

    self.upgradesUI:chooseUpgrade({
        upgrades = randomUpgrades,
        maxTier = self.player.maxUpgradeTier,
    }, function(upgrade)
        print("Applying upgrade " .. upgrade.name)
        self.player:upgrade(upgrade.name)

        self.upgradesUI:cancelChoosingUpgrade()
    end)

    self.game:defer(self.intermissionDuration, function()
        self.upgradesUI:cancelChoosingUpgrade()

        self:nextWave()
    end)
end

function PlayState:nextWave()
    if not self.waveFinishedSpawning then
        return
    end

    tablef.clear(self.enemies)

    self.data.wave = self.data.wave + 1
    self.waveFinishedSpawning = false

    print("Wave " .. self.data.wave .. " started")

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
end

function PlayState:update(dt)
    State.update(self, dt)

    self.upgradesUI:update()
    self.shotTypeUI:update()
end

return PlayState
