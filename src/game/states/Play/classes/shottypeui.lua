local oo = require 'libs.oo'
local tablef = require 'classes.tablef'
local signal = require 'libs.signal'
local import = require 'libs.import'
local UI, Frame, Text = import({ 'UI', 'Frame', 'Text' }, 'classes.ui')
local Vector2 = require 'types.vector2'
local UDim2 = require 'types.udim2'
local Color4 = require 'types.color4'

local ShotTypeUI = oo.class(UI)

function ShotTypeUI:init(game)
    UI.init(self, game)

    local frame = self:addChild(Frame)
    frame.size = UDim2(0.75, 0, 0.5, 0)
    frame.position = UDim2(1, -10, 1, -10)
    frame.anchorPoint = Vector2(1, 1)
    frame.color = Color4(0, 0, 0, 0)
    self.frame = frame

    self.data = {}
end

function ShotTypeUI:update()
    UI.update(self)

    if not self.game.current.player then
        return
    end

    if not tablef.eq(self.game.current.player.shotTypes, self.data) then
        self.data = tablef.copy(self.game.current.player.shotTypes)
        self:fillWithData(self.data)
    end
end

function ShotTypeUI:fillWithData(data)
    self.frame:clearAllChildren()

    local margin = 4
    local cellSize = 24

    for i, shotType in ipairs(data) do
        local anchorPoint = Vector2(1, 1)
        local size = UDim2(1, 0, 0, cellSize)
        local position = UDim2(1, 0, 1, -(i - 1) * (cellSize + margin))

        local text = self.frame:addChild(Text)
        text:setFont(cellSize)
        text.color = Color4(0, 0, 0, 0)
        text.textColor = shotType.selected and Color4(1, 1, 1, 1) or Color4(0.5, 0.5, 0.5, 1)
        text.text = shotType.name
        text.textAlignX = 'right'
        text.size = size
        text.position = position
        text.anchorPoint = anchorPoint
    end
end

return ShotTypeUI
