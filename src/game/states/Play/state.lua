local oo = require 'libs.oo'
local tablef = require 'classes.tablef'
local State = require 'classes.state'
local Vector2 = require 'types.vector2'

local Camera = require 'classes.camera'
local Player = require 'classes.player'
local Enemy = require 'classes.enemy'

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
    self.intermissionDuration = 2

    self.enemies = {}
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
            self.game:defer(self.intermissionDuration, function()
                self:nextWave()
            end)
        end
    end)

    table.insert(self.enemies, {
        enemy = enemy,
    })
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

return PlayState
