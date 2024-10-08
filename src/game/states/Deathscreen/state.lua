local oo = require "libs.oo"
local State = require "classes.state"
local import = require "libs.import"
local Vector2 = import "types.vector2"
local Color4 = import "types.color4"
local UDim2 = import "types.udim2"
local UI, Frame, Text = import({ 'UI', 'Frame', 'Text' }, 'classes.ui')

local Deathscreen = oo.class(State)

function Deathscreen:init(game)
    State.init(self, game)
    self.name = "Deathscreen"

    self.UI = UI(self.game)

    self.youDiedText = self.UI:addChild(Text)
    self.youDiedText:setFont(48)
    self.youDiedText.textColor = Color4.fromHex("#AE2012")
    self.youDiedText.color = Color4(0, 0, 0, 0)
    self.youDiedText.text = "You died!"
    self.youDiedText.size = UDim2(1, 0, 0, 50)
    self.youDiedText.anchorPoint = Vector2(0.5, 0.5)
    self.youDiedTextTargetPosition = UDim2(0.5, 0, 0.2, 0)

    self.statsFrame = self.UI:addChild(Frame)
    self.statsFrame.size = UDim2(0.4, 0, 0.4, 0)
    self.statsFrame.style = "line"
    self.statsFrameTargetPosition = UDim2(0.5, 0, 0.5, 0)

    self.createStatElement = function(name, value)
        local frame = self.statsFrame:addChild(Frame)
        frame.size = UDim2(1, 0, 0.2, 0)
        frame.position = UDim2(0, 0, 0.2 * (#self.statsFrame.children - 1) + 0.05, 0)
        frame.anchorPoint = Vector2(0, 0)
        frame.color = Color4(0, 0, 0, 0)

        local nameText = frame:addChild(Text)
        nameText.position = UDim2(0, 0, 0, 0)
        nameText.anchorPoint = Vector2(0, 0)
        nameText.size = UDim2(0.5, 0, 1, 0)
        nameText.text = name
        nameText.size = UDim2(0.5, 0, 1, 0)
        nameText:setFont(24)
        nameText.color = Color4(0, 0, 0, 0)
        nameText.textColor = Color4.fromHex("#FFFFFF")

        local valueText = frame:addChild(Text)
        valueText.position = UDim2(0.5, 0, 0, 0)
        valueText.anchorPoint = Vector2(0, 0)
        valueText.size = UDim2(0.5, 0, 1, 0)
        valueText.text = value
        valueText:setFont(24)
        valueText.color = Color4(0, 0, 0, 0)
        valueText.textColor = Color4.fromHex("#FFFFFF")
    end

    self.retryButton = self.UI:addChild(Text)
    self.retryButton.color = Color4.fromHex("#EE9B00")
    self.retryButton.textColor = Color4.fromHex("#FFFFFF")
    self.retryButton:setFont(24)
    self.retryButton.text = "Retry?"
    self.retryButton.size = UDim2(0.2, 0, 0.1, 0)
    self.retryButton.anchorPoint = Vector2(0.5, 0)
    self.retryButtonTargetPosition = UDim2(0.5, 0, 0.85, 0)

    self.retryButton.mouseDown:connect(function()
        self.game:setState("PlayState")
    end)
end

function Deathscreen:enter(prevState, data)
    State.enter(self, prevState, data)

    self.createStatElement("Score", data.score)
    self.createStatElement("Wave", data.wave)

    self.youDiedText.position = UDim2(0.5, 0, 0.5, 0)
    self.statsFrame.position = UDim2(0.5, 0, 1, 1)
    self.statsFrame.anchorPoint = Vector2(0.5, 0)
    self.retryButton.position = UDim2(0.5, 0, 1, 1)

    self.game:defer(1, function()
        local t1 = 0.5
        self.youDiedText:animate("position", self.youDiedTextTargetPosition, t1)

        self.statsFrame:animate("position", self.statsFrameTargetPosition, t1)
        self.statsFrame:animate("anchorPoint", Vector2(0.5, 0.5), t1)

        self.game:defer(t1 + 1, function()
            self.retryButton:animate("position", self.retryButtonTargetPosition, 0.5)
            self.retryButton:animate("anchorPoint", Vector2(0.5, 0), 0.5)
        end)
    end)

    self.game.sound:play("death", 2)
end

function Deathscreen:exit()
    State.exit(self)

    self.statsFrame:clearAllChildren()

    self.youDiedText.position = UDim2(0.5, 0, 0.5, 0)
    self.statsFrame.position = UDim2(0.5, 0, 1, 1)
    self.statsFrame.anchorPoint = Vector2(0.5, 0)
    self.retryButton.position = UDim2(0.5, 0, 1, 1)
end

function Deathscreen:update(dt)
    State.update(self, dt)

    self.UI:update(dt)
end

function Deathscreen:draw()
    State.draw(self)

    self.UI:draw()
end

return Deathscreen
