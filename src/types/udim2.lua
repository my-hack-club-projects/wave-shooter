local oo = require 'libs.oo'
local UDim = require 'types.udim'
local Vector2 = require 'types.vector2'

local UDim2 = oo.class()

function UDim2:init(scaleX, offsetX, scaleY, offsetY)
    self.x = UDim(scaleX, offsetX)
    self.y = UDim(scaleY, offsetY)
end

function UDim2:toVector2(size)
    return Vector2(self.x:toPixels(size.x), self.y:toPixels(size.y))
end

function UDim2:tostring()
    return 'UDim2(' .. self.x:tostring() .. ', ' .. self.y:tostring() .. ')'
end

return UDim2
