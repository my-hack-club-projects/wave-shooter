local oo = require "libs.oo"

local Listener = oo.class()

function Listener:init(f, scope)
    self.func = f
    self.scope = scope
    self.signal = nil
end

function Listener:__call(...)
    if self.scope == nil then
        self.func(...)
    else
        self.func(self.scope, ...)
    end
end

function Listener:disconnect()
    self.signal:remove(self)
end

local Signal = oo.class()

function Signal:init()
    self.listeners = {}
end

local function getListenerPos(self, func, scope)
    for pos, l in ipairs(self.listeners) do
        if l.func == func and l.scope == scope then
            return pos
        end
    end
end

function Signal:connect(func, scope)
    local l = Listener.new(func, scope)
    l.signal = self
    table.insert(self.listeners, l)
    return l
end

function Signal:once(func, scope)
    local l = self:connect(func, scope)
    l.once = true
    return l
end

function Signal:remove(l)
    for i, listener in ipairs(self.listeners) do
        if listener == l then
            table.remove(self.listeners, i)
            return
        end
    end
end

function Signal:dispatch(...)
    for i, l in ipairs(self.listeners) do
        l(...)
        if l.once then
            table.remove(self.listeners, i)
        end
    end
end

function Signal:__call(...)
    self:dispatch(...)
end

return Signal
