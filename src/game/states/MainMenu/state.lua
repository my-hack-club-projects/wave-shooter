local oo = require "libs.oo"
local State = require "classes.state"
local import = require "libs.import"
local Vector2 = import "types.vector2"
local Color4 = import "types.color4"
local UDim2 = import "types.udim2"
local UI, Frame, Text = import({ 'UI', 'Frame', 'Text' }, 'classes.ui')

local Entity = import "classes.entity"

local MainMenu = oo.class(State)

function MainMenu:init(game)
    State.init(self, game)
    self.name = "MainMenu"

    self.UI = UI(self.game)

    -- no animations here, just static UI elements

    self.titleText = self.UI:addChild(Text)
    self.titleText:setFont(48)
    self.titleText.textColor = Color4.fromHex("#AE2012")
    self.titleText.color = Color4(0, 0, 0, 0)
    self.titleText.text = "Wave shooter"
    self.titleText.size = UDim2(1, 0, 0, 50)
    self.titleText.position = UDim2(0.5, 0, 0.2, 0)
    self.titleText.anchorPoint = Vector2(0.5, 0.5)

    self.startButton = self.UI:addChild(Text)
    self.startButton:setFont(24)
    self.startButton.color = Color4.fromHex("#EE9B00")
    self.startButton.textColor = Color4.fromHex("#FFFFFF")
    self.startButton.text = "Play"
    self.startButton.size = UDim2(0.2, 0, 0.1, 0)
    self.startButton.position = UDim2(0.5, 0, 0.5, 0)
    self.startButton.anchorPoint = Vector2(0.5, 0.5)

    self.startButton.mouseDown:once(function()
        self.game:setState("PlayState")
    end)
end

function MainMenu:enter()
    State.enter(self)

    self.floorImage = self.entity.new(
        Entity,
        {
            game = self.game,
            position = Vector2(0, 0),
            size = Vector2(200, 200),
            color = Color4.fromHex("#005F73"),
            zindex = -1,
            image = love.graphics.newImage("assets/images/floor.png"),
        }
    )

    self.music = self.game.sound:play("main_menu_music", 0.4)
    self.music:setLooping(true)
end

function MainMenu:exit()
    State.exit(self)

    self.music:stop()
end

function MainMenu:update(dt)
    State.update(self, dt)

    self.UI:update(dt)
end

function MainMenu:draw()
    State.draw(self)

    self.UI:draw()
end

return MainMenu
