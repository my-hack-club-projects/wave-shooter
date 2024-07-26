local oo = require 'libs.oo'

local Vector2 = oo.class()

function Vector2:init(x, y, _skipUnit)
    self.x = x or 0
    self.y = y or 0

    self.magnitude = math.sqrt(self.x * self.x + self.y * self.y)

    if not _skipUnit then
        self.unit = Vector2(self.x / self.magnitude, self.y / self.magnitude, true)
    end
end

function Vector2:__add(other)
    return Vector2(self.x + other.x, self.y + other.y)
end

function Vector2:__sub(other)
    return Vector2(self.x - other.x, self.y - other.y)
end

function Vector2:__mul(other)
    if type(other) == "number" then
        return Vector2(self.x * other, self.y * other)
    else
        return Vector2(self.x * other.x, self.y * other.y)
    end
end

function Vector2:__div(other)
    if type(other) == "number" then
        return Vector2(self.x / other, self.y / other)
    else
        return Vector2(self.x / other.x, self.y / other.y)
    end
end

function Vector2:cross(other)
    return self.x * other.y - self.y * other.x
end

function Vector2:dot(other)
    return self.x * other.x + self.y * other.y
end

function Vector2:__eq(other)
    return self.x == other.x and self.y == other.y
end

function Vector2:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ")"
end

return Vector2
