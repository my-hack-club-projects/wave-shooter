local oo = require 'libs.oo'
local mathf = require 'classes.mathf'
local signal = require 'libs.signal'
local Instance = require 'classes.instance'
local Vector2 = require 'types.vector2'
local UDim2 = require 'types.udim2'
local Color4 = require 'types.color4'

local UI = oo.class(Instance)

function UI:init(game)
    assert(game, "UI needs a game")

    Instance.init(self)

    self.game = game
    self.absoluteSize = Vector2(love.graphics.getDimensions())
    self.absolutePosition = Vector2(0, 0)

    self.visible = true

    self.resizeListener = self.game.signals.resize:connect(function(width, height)
        self.absoluteSize = Vector2(width, height)
    end)
end

function UI:sort()
    table.sort(self.children, function(a, b)
        return a.zindex < b.zindex
    end)
end

function UI:addChild(...)
    local child = Instance.addChild(self, ...)
    self:sort()
    return child
end

function UI:removeChild(child)
    Instance.removeChild(self, child)
    self:sort()
end

function UI:update()
    for i, child in ipairs(self.children) do
        child:update()
    end
end

function UI:draw()
    if not self.visible then
        return
    end

    for i, child in ipairs(self.children) do
        child:draw()
    end
end

local WorldUI = oo.class(UI)

function WorldUI:init(game)
    UI.init(self, game)

    self.resizeListener:disconnect()

    self.position = Vector2(0, 0)
    self.size = Vector2(1, 1)
end

function WorldUI:update()
    local unitSize = self.game.UnitSize

    self.absoluteSize = self.size * unitSize
    self.absolutePosition = self.position * unitSize

    UI.update(self)
end

local UIElement = oo.class(Instance)

function UIElement:init()
    Instance.init(self)

    self.position = UDim2()
    self.size = UDim2()
    self.anchorPoint = Vector2(0.5, 0.5)
    self.color = Color4()
    self.zindex = 0
    self.style = "fill"

    self.mouseDown = signal.new()
    self.mouseUp = signal.new()
    self.mouseEnter = signal.new()
    self.mouseLeave = signal.new()

    self.mouseInside = false
    self.mousePressed = true -- So that the first frame doesn't trigger the mouseDown event
end

function UIElement:findGame()
    local game = nil
    local current = self
    repeat
        if current.game then
            game = current.game
        end

        if current.parent then
            current = current.parent
        else
            break
        end
    until game ~= nil
    return game
end

function UIElement:animate(property, goal, duration)
    local game = self:findGame()

    assert(game)

    local startValue = self[property]

    assert(startValue, "Property '" .. property .. "' does not exist on '" .. tostring(self) .. "'!")

    local elapsed = 0
    local listener
    listener = game.signals.preUpdate:connect(function(dt)
        elapsed = elapsed + dt

        if elapsed > duration then
            listener:disconnect()
            return
        end

        local value = mathf.lerp(startValue, goal, elapsed / duration)

        self[property] = value
    end)
end

function UIElement:calculateAbs()
    local parent = self.parent
    local parentAbsoluteSize = parent and parent.absoluteSize or Vector2(love.graphics.getDimensions())
    local parentAbsolutePosition = parent and parent.absolutePosition or Vector2(0, 0)

    local w = parentAbsoluteSize.x * self.size.x.scale + self.size.x.offset
    local h = parentAbsoluteSize.y * self.size.y.scale + self.size.y.offset

    local x = parentAbsolutePosition.x + parentAbsoluteSize.x * self.position.x.scale + self.position.x.offset -
        w * self.anchorPoint.x
    local y = parentAbsolutePosition.y + parentAbsoluteSize.y * self.position.y.scale + self.position.y.offset -
        h * self.anchorPoint.y

    self.absolutePosition = Vector2(x, y)
    self.absoluteSize = Vector2(w, h)
end

function UIElement:update()
    self:calculateAbs()

    -- Handle mouse events
    local mousePosition = Vector2(love.mouse.getPosition())
    local x, y = self.absolutePosition.x, self.absolutePosition.y
    local w, h = self.absoluteSize.x, self.absoluteSize.y

    local inside = mousePosition.x >= x and mousePosition.x <= x + w and
        mousePosition.y >= y and mousePosition.y <= y + h

    if inside then
        if not self.mouseInside then
            self.mouseEnter:dispatch()
        end
    else
        if self.mouseInside then
            self.mouseLeave:dispatch()
        end
    end

    self.mouseInside = inside

    if love.mouse.isDown(1) and self.mouseInside and not self.mousePressed then
        self.mouseDown:dispatch()
    elseif not love.mouse.isDown(1) and self.mouseInside and self.mousePressed then
        self.mouseUp:dispatch()
    end

    self.mousePressed = love.mouse.isDown(1)

    -- Update children
    for i, child in ipairs(self.children) do
        child:update()
    end
end

function UIElement:drawElement()
    love.graphics.rectangle(self.style, 0, 0, self.absoluteSize.x, self.absoluteSize.y)
end

function UIElement:draw()
    if not self.absoluteSize or not self.absolutePosition then
        self:calculateAbs()
    end

    love.graphics.push()

    love.graphics.translate(self.absolutePosition.x, self.absolutePosition.y)
    love.graphics.setColor(self.color:unpack())

    self:drawElement()

    love.graphics.pop()

    for i, child in ipairs(self.children) do
        child:draw()
    end
end

local Frame = oo.class(UIElement)

function Frame:init()
    UIElement.init(self)
end

function Frame:drawElement()
    love.graphics.rectangle(self.style, 0, 0, self.absoluteSize.x, self.absoluteSize.y)
end

local Text = oo.class(UIElement)

function Text:init()
    UIElement.init(self)

    self.text = ""
    self.textAlignX = "center"
    self.textAlignY = "center"
    self.font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 8)

    self.textColor = Color4(0, 0, 0, 1)
end

function Text:setFont(font)
    if type(font) == "number" then
        font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", font)
    end

    self.font = font
end

function Text:drawElement()
    -- Draw  the BG element
    UIElement.drawElement(self)

    -- Draw the text (centered, must NOT get out of bounds of the element)
    local font = self.font
    local text = self.text
    local x = self.absoluteSize.x / 2 - font:getWidth(text) / 2
    local y = self.absoluteSize.y / 2 - font:getHeight() / 2

    love.graphics.setFont(font)
    love.graphics.setColor(self.textColor:unpack())

    if self.textAlignY == "top" then
        y = 0
    elseif self.textAlignY == "bottom" then
        y = self.absoluteSize.y - font:getHeight()
    else
        y = self.absoluteSize.y / 2 - font:getHeight() / 2
    end

    love.graphics.printf(text, 0, y, self.absoluteSize.x, self.textAlignX or "center")
end

return {
    UI = UI,
    WorldUI = WorldUI,
    UIElement = UIElement,
    Frame = Frame,
    Text = Text
}
