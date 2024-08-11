local oo = require "libs.oo"
local signal = require "libs.signal"
local Vector2 = require "types.vector2"
local Color4 = require "types.color4"

local Entity = require "classes.entity"
local Boundary = oo.class(Entity)

function Boundary:init(props)
    Entity.init(self, props)

    self.name = "Boundary"
    self.thickness = 1000
    self.radius = props.radius or 1

    self.color = Color4.fromHex("#AE2012")

    self.zindex = 100

    self.entityExited = signal.new()
end

function Boundary:update()
    for _, entity in ipairs(self.game.current.entity.getAll()) do
        if entity ~= self then
            local distance = (entity.position - self.position).magnitude + entity.size.magnitude / 2
            if distance > self.radius then
                self.entityExited:dispatch(entity)
            end
        end
    end
end

function Boundary:draw()
    local unitSize = self.game.UnitSize

    local r = self.radius * unitSize
    local x, y = self.position.x * unitSize + r * (self.anchorPoint.x * 2 - 1),
        self.position.y * unitSize + r * (self.anchorPoint.y * 2 - 1)

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.setColor(self.color:unpack())

    love.graphics.setLineWidth(self.thickness)
    love.graphics.circle("line", 0, 0, r + self.thickness / 2)
    love.graphics.setLineWidth(1)

    love.graphics.pop()
end

return Boundary
