local oo = require 'libs.oo'
local signal = require 'libs.signal'

local Sound = require 'classes.sound'

local Game = oo.class()

function Game:init()
    -- states
    self.states = {}
    self.current = nil
    self.initial = nil

    -- sound
    self.sound = Sound()

    -- signals
    self.signals = {
        stateChange = signal.new(),

        resize = signal.new(),

        keypressed = signal.new(),
        keyreleased = signal.new(),
        mousepressed = signal.new(),
        mousereleased = signal.new(),
        mousemoved = signal.new(),
        wheelmoved = signal.new(),
        textinput = signal.new(),

        preDraw = signal.new(),
        postDraw = signal.new(),
        preUpdate = signal.new(),
        postUpdate = signal.new(),
    }

    -- properties
    self.UnitSize = 32

    self.width = 0
    self.height = 0

    -- other
    self.shared = {} -- shared data between states

    -- handle input signals
    local function forwardSignal(name)
        return function(...)
            self.signals[name]:dispatch(...)
        end
    end

    love.keypressed = forwardSignal("keypressed")
    love.keyreleased = forwardSignal("keyreleased")
    love.mousepressed = forwardSignal("mousepressed")
    love.mousereleased = forwardSignal("mousereleased")
    love.mousemoved = forwardSignal("mousemoved")
    love.wheelmoved = forwardSignal("wheelmoved")
    love.textinput = forwardSignal("textinput")
    love.resize = forwardSignal("resize")

    self.defers = {}

    -- compute dimensions
    self:computeDimensionsUnit()

    self.signals.resize:connect(self.computeDimensionsUnit, self)
end

function Game:loadConfig(config)
    for k, v in pairs(config) do
        self[k] = v
    end
end

function Game:load()
    -- runs once on love.load after all states have been loaded
    math.randomseed(os.time())

    love.graphics.setDefaultFilter("nearest", "nearest")

    assert(self.initial, "No initial state for Game")
    self:setState(self.initial)
end

function Game:loadState(stateClass)
    local state = stateClass(self)

    self.states[state.name] = state
end

function Game:setState(name)
    assert(self.states[name], "State does not exist")

    if self.current then
        self.current:exit()
    end

    local prev = self.current

    self.current = self.states[name]
    self.current.prevState = prev
    self.current:enter(prev)
end

function Game:getState()
    return self.current
end

function Game:resetState()
    self.current:exit()
    self.current:enter()
end

function Game:computeDimensionsUnit()
    self.width = love.graphics.getWidth() / self.UnitSize
    self.height = love.graphics.getHeight() / self.UnitSize
end

function Game:update(dt)
    self.signals.preUpdate:dispatch(dt)

    for i = #self.defers, 1, -1 do
        local defer = self.defers[i]
        if love.timer.getTime() - defer.start >= defer.duration then
            defer.func()
            table.remove(self.defers, i)
        end
    end

    if self.current then
        self.current:update(dt)
    end

    self.signals.postUpdate:dispatch(dt)
end

function Game:draw()
    self.signals.preDraw:dispatch()

    if self.current then
        self.current:draw()
    end

    self.signals.postDraw:dispatch()
end

function Game:defer(seconds, func)
    table.insert(
        self.defers,
        {
            start = love.timer.getTime(),
            duration = seconds,
            func = func,
        }
    )
end

function Game.__tostring()
    return "<GameObject>"
end

return Game
