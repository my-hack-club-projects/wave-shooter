local oo = require 'libs.oo'
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
    for i, child in ipairs(self.children) do
        child:draw()
    end
end

local UIElement = oo.class(Instance)

function UIElement:init()
    Instance.init(self)

    self.position = UDim2()
    self.size = UDim2()
    self.anchorPoint = Vector2(0.5, 0.5)
    self.color = Color4()
end

function UIElement:drawElement()
    love.graphics.rectangle("outline", 0, 0, self.absoluteSize.x, self.absoluteSize.y)
end

function UIElement:draw()
    local parent = self.parent
    local parentAbsoluteSize = parent and parent.absoluteSize or Vector2(love.graphics.getDimensions())
    local parentAbsolutePosition = parent and parent.absolutePosition or Vector2(0, 0)

    local x = parentAbsolutePosition.x + parentAbsoluteSize.x * self.position.x.scale + self.position.x.offset -
        self.size.x.scale * self.anchorPoint.x
    local y = parentAbsolutePosition.y + parentAbsoluteSize.y * self.position.y.scale + self.position.y.offset -
        self.size.y.scale * self.anchorPoint.y

    local w = parentAbsoluteSize.x * self.size.x.scale + self.size.x.offset
    local h = parentAbsoluteSize.y * self.size.y.scale + self.size.y.offset

    self.absolutePosition = Vector2(x, y)
    self.absoluteSize = Vector2(w, h)

    love.graphics.push()

    love.graphics.translate(x, y)
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
    love.graphics.rectangle("fill", 0, 0, self.absoluteSize.x, self.absoluteSize.y)
end

return {
    UI = UI,
    UIElement = UIElement,
    Frame = Frame,
}
