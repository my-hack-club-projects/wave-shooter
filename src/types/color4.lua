local oo = require 'libs.oo'
local mathf = require 'classes.mathf'

local Color4 = oo.class()

local function colorOperation(color1, color2, operation)
    if type(color1) == 'number' then
        color1 = Color4(color1, color1, color1, 1)
    end
    if type(color2) == 'number' then
        color2 = Color4(color2, color2, color2, 1)
    end

    local t = {}

    for i = 1, mathf.max(#color1.components, #color2.components) do
        t[i] = operation(color1.components[i] or 0, color2.components[i] or 0)
    end

    return Color4(table.unpack(t))
end

function Color4:init(r, g, b, a)
    self.components = {}

    for i, v in ipairs({ r or 1, g or 1, b or 1, a or 1 }) do
        self.components[i] = mathf.clamp(v, 0, 1)
    end

    self.r = self.components[1]
    self.g = self.components[2]
    self.b = self.components[3]
    self.a = self.components[4]

    self.fromRGBA = nil
    self.fromHex = nil
    self.fromHSVA = nil
end

function Color4.fromRGBA(r, g, b, a)
    return Color4(r / 255, g / 255, b / 255, (a or 255) / 255)
end

function Color4.fromHex(hex)
    hex = hex:gsub('#', '')
    return Color4.fromRGBA(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16),
        tonumber(hex:sub(7, 8) or 'FF', 16)
    )
end

function Color4.fromHSVA(h, s, v, a)
    h, s, v, a = h / 360, s / 100, v / 100, a / 100

    if s <= 0 then
        return Color4(v, v, v, a)
    end

    h = h * 6
    local c = v * s
    local x = (1 - math.abs((h % 2) - 1)) * c
    local m, r, g, b = (v - c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return Color4(r + m, g + m, b + m, a)
end

function Color4:__add(other)
    return colorOperation(self, other, function(a, b) return a + b end)
end

function Color4:__sub(other)
    return colorOperation(self, other, function(a, b) return a - b end)
end

function Color4:__mul(other)
    return colorOperation(self, other, function(a, b) return a * b end)
end

function Color4:__div(other)
    return colorOperation(self, other, function(a, b) return a / b end)
end

function Color4:__eq(other)
    return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

function Color4:lerp(other, t)
    return Color4(
        mathf.lerp(self.r, other.r, t),
        mathf.lerp(self.g, other.g, t),
        mathf.lerp(self.b, other.b, t),
        mathf.lerp(self.a, other.a, t)
    )
end

function Color4:unpack()
    return self.r, self.g, self.b, self.a
end

function Color4:__tostring()
    return string.format('<Color4 (%f, %f, %f, %f)>', self.r, self.g, self.b, self.a)
end

return Color4
