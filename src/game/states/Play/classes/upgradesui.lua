-- local oo = require 'libs.oo'
-- local import = require 'libs.import'
-- local UI, Text = import({ 'UI', 'Text' }, 'classes.ui')
-- local UDim2 = require 'types.udim2'
-- local Vector2 = require 'types.vector2'
-- local Color4 = require 'types.color4'

local helium = require 'libs.helium'

local UpgradesUI = helium(function(param, view)
    return function()
        -- Main container
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, view.h, view.w)

        -- Title
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print("Upgrades", 10, 10)

        -- Upgrade buttons
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", 10, 30, 100, 100)
        love.graphics.rectangle("fill", 120, 30, 100, 100)
        love.graphics.rectangle("fill", 230, 30, 100, 100)
        love.graphics.rectangle("fill", 340, 30, 100, 100)
    end
end)

return UpgradesUI
