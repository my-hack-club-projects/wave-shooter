local oo = require 'libs.oo'

local Sound = oo.class()

local soundsDirs = {
    "assets/sounds/"
}

function Sound:init()
    self.names = {}
    self.sources = {}

    self:scanDirs()
end

function Sound:scanDirs()
    for i, dir in ipairs(soundsDirs) do
        local files = love.filesystem.getDirectoryItems(dir)
        for j, file in ipairs(files) do
            local name = file:match("(.+)%..+")
            self.names[name] = dir .. file
        end
    end
end

function Sound:newSource(name, type)
    if not self.sources[name] then
        self.sources[name] = {}
    end

    local source = love.audio.newSource(self.names[name], type or "static")

    table.insert(self.sources[name], source)

    return source
end

function Sound:getInactiveSource(name)
    if not self.sources[name] then
        return self:newSource(name)
    end

    for i, source in ipairs(self.sources[name]) do
        if not source:isPlaying() then
            return source
        end
    end
end

function Sound:play(name, volume)
    local source = self:getInactiveSource(name) or self:newSource(name)

    source:setVolume(volume or 1)

    source:play()
    return source
end

return Sound
