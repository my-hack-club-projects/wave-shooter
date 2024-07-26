local oo = require 'libs.oo'
local State = require 'classes.state'

local DemoState = oo.class(State)

function DemoState:init(game)
    State.init(self, game)

    self.name = "DemoState"
end

function DemoState:enter(prevState)
    State.enter(self, prevState)
end

function DemoState:exit()
    State.exit(self)
end

function DemoState:update(dt)
    State.update(self, dt)
end

function DemoState:draw()
    State.draw(self)

    love.graphics.setColor(255, 255, 255)
    love.graphics.print("DemoState", 10, 10)
end

return DemoState
