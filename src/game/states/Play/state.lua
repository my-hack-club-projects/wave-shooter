local oo = require 'libs.oo'
local State = require 'classes.state'

local Camera = require 'classes.camera'
local Player = require 'classes.player'
local Enemy = require 'classes.enemy'

local PlayState = oo.class(State)

function PlayState:init(game)
    State.init(self, game)

    self.name = "PlayState"
    self.camera = Camera(self.game)
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

    self.entity.new(
        Enemy,
        {
            target = self.player
        }
    )
end

return PlayState
