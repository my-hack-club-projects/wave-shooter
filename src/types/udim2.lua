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

function UDim2:__tostring()
    return 'UDim2(' .. self.x:tostring() .. ', ' .. self.y:tostring() .. ')'
end

function UDim2:__add(other)
    if type(other) == 'number' then
        return UDim2(self.x.scale + other, self.x.offset, self.y.scale + other, self.y.offset)
    end

    return UDim2(self.x.scale + other.x.scale, self.x.offset + other.x.offset, self.y.scale + other.y.scale,
        self.y.offset + other.y.offset)
end

function UDim2:__sub(other)
    if type(other) == 'number' then
        return UDim2(self.x.scale - other, self.x.offset, self.y.scale - other, self.y.offset)
    end

    return UDim2(self.x.scale - other.x.scale, self.x.offset - other.x.offset, self.y.scale - other.y.scale,
        self.y.offset - other.y.offset)
end

function UDim2:__mul(other)
    if type(other) == 'number' then
        return UDim2(self.x.scale * other, self.x.offset, self.y.scale * other, self.y.offset)
    end

    return UDim2(self.x.scale * other.x.scale, self.x.offset * other.x.offset, self.y.scale * other.y.scale,
        self.y.offset * other.y.offset)
end

function UDim2:__div(other)
    if type(other) == 'number' then
        return UDim2(self.x.scale / other, self.x.offset, self.y.scale / other, self.y.offset)
    end

    return UDim2(self.x.scale / other.x.scale, self.x.offset / other.x.offset, self.y.scale / other.y.scale,
        self.y.offset / other.y.offset)
end

function UDim2:__eq(other)
    return self.x == other.x and self.y == other.y
end

return UDim2
