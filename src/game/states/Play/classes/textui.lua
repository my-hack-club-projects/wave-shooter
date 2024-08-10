local oo = require "libs.oo"
local import = require "libs.import"

local Color4 = import "types.color4"
local Vector2 = import "types.vector2"

local UI, Frame, Text = import({ 'UI', 'Frame', 'Text' }, 'classes.ui')

local TextUI = oo.class(UI)

function TextUI:init(game, props)
    assert(props.size, "TextUI: size is required")
    assert(props.position, "TextUI: position is required")

    UI.init(self, game)
    self.textFormat = props.textFormat or "%d"
    self.value = props.value or 0

    self.textLabel = self:addChild(Text)
    self.textLabel.text = string.format(self.textFormat, self.value)
    self.textLabel:setFont(props.font or 24)
    self.textLabel.text = string.format(self.textFormat, self.value)
    self.textLabel:setFont(props.font, props.fontSize)
    self.textLabel.textColor = props.textColor or Color4(1, 1, 1, 1)
    self.textLabel.color = props.color or Color4(0, 0, 0, 0)
    self.textLabel.textAlignX = props.textAlignX or "center"
    self.textLabel.textAlignY = props.textAlignY or "center"
    self.textLabel.size = props.size
    self.textLabel.position = props.position
    self.textLabel.anchorPoint = props.anchorPoint or Vector2(0.5, 0.5)
end

function TextUI:setValue(value)
    self.value = value
    self.textLabel.text = string.format(self.textFormat, self.value)
end

return TextUI
