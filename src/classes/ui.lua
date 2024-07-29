local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local Vector2 = require 'types.vector2'
local UDim2 = require 'types.udim2'
local Color4 = require 'types.color4'
local Signal = require 'libs.signal'

local UI = oo.class()

function UI:init()
    self.position = UDim2.new(0, 0, 0, 0)
    self.size = UDim2.new(0, 0, 0, 0)
    self.color = Color4(1, 1, 1, 1)

    self.mouseDown = Signal()
    self.mouseUp = Signal()
    self.mouseEnter = Signal()
    self.mouseLeave = Signal()

    self.hovered = false
    self.pressed = false

    self.parent = nil
end

function UI:update()
    local mx, my = love.mouse.getPosition()
    local hovered = self:contains(mx, my)

    if hovered and not self.hovered then
        self.hovered = true
        self.mouseEnter:dispatch()
    elseif not hovered and self.hovered then
        self.hovered = false
        self.mouseLeave:dispatch()
    end

    if hovered and love.mouse.isDown(1) then
        if not self.pressed then
            self.pressed = true
            self.mouseDown:dispatch()
        end
    elseif self.pressed then
        self.pressed = false
        self.mouseUp:dispatch()
    end
end

function UI:contains(x, y)
    local dimensions = self:getDimensions()
    local position = self:getPosition()
    local size = self.size:toVector2(dimensions)

    return
        x >= position.x - size.x / 2
        and x <= position.x + size.x / 2
        and y >= position.y - size.y / 2
        and y <= position.y + size.y / 2
end

function UI:getDimensions()
    if self.parent then
        return self.size:toVector2(self.parent:getDimensions())
    else
        return Vector2(love.graphics.getDimensions())
    end
end

function UI:getPosition()
    if self.parent then
        local parentPosition = self.parent:getPosition()

        local combined = UDim2(
            self.position.x.scale,
            self.position.x.offset + parentPosition.x,
            self.position.y.scale,
            self.position.y.offset + parentPosition.y
        )

        return combined:toVector2(self.parent:getDimensions())
    else
        return self.position:toVector2(Vector2(love.graphics.getDimensions()))
    end
end

function UI:attach()
    love.graphics.push()

    local viewportSize = self:getDimensions()
    local pos = self:getPosition()

    love.graphics.translate(pos.x, pos.y)
    love.graphics.setColor(self.color:unpack())
end

function UI:detach()
    love.graphics.pop()
end

local Text = oo.class(UI)

function Text:init()
    UI.init(self)

    self.text = ""
    self.font = love.graphics.newFont(12)
end

function Text:setFont(font)
    self.font = font
end

function Text:setText(text)
    self.text = text
end

function Text:contains(x, y)
    local dimensions = self:getDimensions()
    local position = self:getPosition()
    local size = Vector2(self.font:getWidth(self.text), self.font:getHeight())

    return
        x >= position.x - size.x / 2
        and x <= position.x + size.x / 2
        and y >= position.y - size.y / 2
        and y <= position.y + size.y / 2
end

function Text:attach()
    local textSize = Vector2(self.font:getWidth(self.text), self.font:getHeight())

    love.graphics.push()
    love.graphics.translate(-textSize.x / 2, -textSize.y / 2)
    love.graphics.setColor(self.color:unpack())
end

function Text:detach()
    love.graphics.pop()
end

function Text:draw()
    UI.attach(self)
    self:attach()

    love.graphics.setFont(self.font)
    love.graphics.print(self.text, 0, 0)

    self:detach()
    UI.detach(self)
end

return {
    UI = UI,
    Text = Text,
}
