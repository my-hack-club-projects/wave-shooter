local oo = require 'libs.oo'
local State = require 'classes.state'

local Camera = require 'classes.camera'
local Player = require 'classes.player'

local PlayState = oo.class(State)

function PlayState:init(game)
    State.init(self, game)

    self.name = "PlayState"
    self.camera = Camera(self.game)
end

function PlayState:enter(prevState)
    State.enter(self, prevState)

    self.entity.new(
        Player,
        {
            speed = 2,
            acceleration = 100,
            drag = 20,
            camera = self.camera,
        }
    )
end

return PlayState
