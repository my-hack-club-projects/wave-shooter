local oo = require 'libs.oo'
local import = require 'libs.import'
local UI, Frame = import({ "UI", "Frame" }, "classes.ui")
local Color4 = import "types.color4"
local UDim2 = import "types.udim2"
local Vector2 = import "types.vector2"
local FadeUI = oo.class(UI)

function FadeUI:init(game)
    UI.init(self, game)

    self.frame = self:addChild(Frame)
    self.frame.color = Color4(0, 0, 0, 1)
    self.frame.size = UDim2(1, 0, 1, 0)
    self.frame.position = UDim2(0, 0, 0, 0)
    self.frame.anchorPoint = Vector2(0, 0)
end

function FadeUI:fadeIn(duration)
    self.frame.color = Color4(0, 0, 0, 0)
    self.frame:animate("color", Color4(0, 0, 0, 1), duration)
end

function FadeUI:fadeOut(duration)
    self.frame.color = Color4(0, 0, 0, 1)
    self.frame:animate("color", Color4(0, 0, 0, 0), duration)
end

return FadeUI
