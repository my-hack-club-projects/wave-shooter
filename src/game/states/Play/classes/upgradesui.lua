local oo = require 'libs.oo'
local import = require 'libs.import'
local UI, Frame, Text = import({ 'UI', 'Frame', 'Text' }, 'classes.ui')
local UDim2 = require 'types.udim2'
local Vector2 = require 'types.vector2'
local Color4 = require 'types.color4'

local UpgradesUI = oo.class(UI)

function UpgradesUI:init(game)
    UI.init(self, game)

    local frame = self:addChild(Frame)
    frame.size = UDim2(0.75, 0, 0.6, 0)
    frame.position = UDim2(0.5, 0, 0.5, 0)
    frame.anchorPoint = Vector2(0.5, 0.5)
    frame.color = Color4.fromHex("#9B2226")

    local title = frame:addChild(Text)
    title:setFont(24)
    title.color = Color4(0, 0, 0, 0)
    title.textColor = Color4(1, 1, 1, 1)
    title.text = "Upgrades"
    title.size = UDim2(1, 0, 0.12, 0)
    title.position = UDim2(0.5, 0, 0, 10)
    title.anchorPoint = Vector2(0.5, 0)

    self.upgradesContainer = frame:addChild(Frame)
    self.upgradesContainer.size = UDim2(0.95, 0, 0.8, 0)
    self.upgradesContainer.position = UDim2(0.5, 0, 0.97, 0)
    self.upgradesContainer.anchorPoint = Vector2(0.5, 1)
    self.upgradesContainer.color = Color4(0, 0, 0, 0)
end

function UpgradesUI:fillWithData(data)
    -- Clear all upgrades
    self.upgradesContainer:clearAllChildren()

    -- Fill the container with upgrades
    local margin = 0.025
    local cellSize = (1 - margin * (#data.upgrades - 1)) / #data.upgrades
    for i, upgrades in ipairs(data.upgrades) do
        local upgradeFrame = self.upgradesContainer:addChild(Frame)
        upgradeFrame.size = UDim2(cellSize, 0, 1, 0)
        upgradeFrame.position = UDim2((cellSize + margin) * (i - 1), 0, 0, 0)
        upgradeFrame.anchorPoint = Vector2(0, 0)
        upgradeFrame.color = Color4.fromHex("#005F73")

        local name = upgradeFrame:addChild(Text)
        name:setFont(16)
        name.color = Color4(0, 0, 0, 0)
        name.textColor = Color4(1, 1, 1, 1)
        name.text = upgrades.name
        name.size = UDim2(0.9, 0, 0.2, 0)
        name.position = UDim2(0.5, 0, 0, 0)
        name.anchorPoint = Vector2(0.5, 0)

        local description = upgradeFrame:addChild(Text)
        description:setFont(12)
        description.color = Color4(0, 0, 0, 0)
        description.textColor = Color4(1, 1, 1, 1)
        description.text = upgrades.description
        description.size = UDim2(0.9, 0, 0.6, 0)
        description.position = UDim2(0.5, 0, 0.2, 0)
        description.anchorPoint = Vector2(0.5, 0)

        local purchase = upgradeFrame:addChild(Text)
        purchase:setFont(12)
        purchase.color = Color4.fromHex("#EE9B00")
        purchase.textColor = Color4(1, 1, 1, 1)
        purchase.text = "Purchase"
        purchase.size = UDim2(1, -20, 0.2, 0)
        purchase.position = UDim2(0.5, 0, 1, -10)
        purchase.anchorPoint = Vector2(0.5, 1)

        upgrades.purchase = purchase
    end
end

function UpgradesUI:chooseUpgrade(data, callback)
    self:fillWithData(data)
    self.visible = true

    self.listeners = {}

    for i, upgrade in ipairs(data.upgrades) do
        table.insert(self.listeners, upgrade.purchase.mouseDown:connect(function()
            for _, listner in ipairs(self.listeners) do
                listner:disconnect()
            end

            callback(upgrade)
        end))
    end
end

function UpgradesUI:cancelChoosingUpgrade()
    for _, listner in ipairs(self.listeners) do
        listner:disconnect()
    end

    self.visible = false
end

return UpgradesUI
