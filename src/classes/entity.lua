local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local Vector2 = require 'types.vector2'
local Color4 = require 'types.color4'

local Entity = oo.class()

function Entity:init(props)
    self.name = props.name or "Entity"
    self.game = props.game or nil

    self.position = props.position or Vector2()
    self.anchorPoint = props.anchorPoint or Vector2(0.5, 0.5)
    self.size = props.size or Vector2()
    self.rotation = props.rotation or 0
    self.color = props.color or Color4()
    self.image = props.image or nil
    self.scaleAxis = props.scaleAxis
    self.zindex = props.zindex or 0

    assert(self.scaleAxis == "x" or self.scaleAxis == "y" or self.scaleAxis == nil, "Invalid scale axis")
end

function Entity.update()
end

function Entity:draw()
    local unitSize = self.game.UnitSize

    local w, h = self.size.x * unitSize, self.size.y * unitSize
    local x, y = self.position.x * unitSize + w * (self.anchorPoint.x * 2 - 1),
        self.position.y * unitSize + h * (self.anchorPoint.y * 2 - 1)

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    love.graphics.setColor(self.color:unpack())

    if self.image then
        local scaleX = w / self.image:getWidth()
        local scaleY = h / self.image:getHeight()

        if self.scaleAxis == "x" then
            scaleY = scaleX * mathf.sign(self.size.y)
        elseif self.scaleAxis == "y" then
            scaleX = scaleY * mathf.sign(self.size.x)
        end

        love.graphics.draw(
            self.image,
            0,
            0,
            0,
            scaleX,
            scaleY,
            self.image:getWidth() / 2,
            self.image:getHeight() / 2
        )
    else
        love.graphics.rectangle("fill", -w / 2, -h / 2, w, h)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function Entity:__tostring()
    return self.name
end

return Entity
