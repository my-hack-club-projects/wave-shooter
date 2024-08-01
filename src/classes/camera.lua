local oo = require 'libs.oo'
local Vector2 = require 'types.vector2'

local Camera = oo.class()

function Camera:init(game)
    assert(game, "Camera must be initialized with a game object")

    self.game = game

    self.position = Vector2(0, 0)
    self.scale = Vector2(1, 1)
    self.rotation = 0

    self.horizontalFov = 35 -- How many units wide the camera can see

    self._attached = false
end

function Camera:getFovScale()
    return love.graphics.getWidth() / self.horizontalFov / self.game.UnitSize
end

function Camera:getUnitSize()
    -- size of the camera in units

    return Vector2(love.graphics.getWidth() / self.game.UnitSize / self:getFovScale(),
        love.graphics.getHeight() / self.game.UnitSize / self:getFovScale()) / self.scale
end

function Camera:attach()
    if self._attached then
        return
    end

    self._attached = true

    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.rotate(-self.rotation)
    love.graphics.scale(self:getFovScale(), self:getFovScale())

    love.graphics.scale(self.scale.x, self.scale.y)
    love.graphics.translate(-self.position.x * self.game.UnitSize, -self.position.y * self.game.UnitSize)
end

function Camera:detach()
    if not self._attached then
        return
    end

    self._attached = false

    love.graphics.pop()
end

function Camera:moveBy(dx, dy)
    self.position.x = self.position.x + dx
    self.position.y = self.position.y + dy
end

function Camera:moveTo(x, y)
    self.position.x = x
    self.position.y = y
end

function Camera:scaleBy(sx, sy)
    self.scale.x = self.scale.x + sx
    self.scale.y = self.scale.y + sy
end

function Camera:scaleTo(sx, sy)
    self.scale.x = sx
    self.scale.y = sy
end

function Camera:rotateBy(dr)
    self.rotation = self.rotation + dr
end

function Camera:rotateTo(r)
    self.rotation = r
end

function Camera:isPointVisible(x, y)
    local halfWidth = love.graphics.getWidth() / 2
    local halfHeight = love.graphics.getHeight() / 2

    local rotatedX = math.cos(self.rotation) * (x - self.position.x) - math.sin(self.rotation) * (y - self.position.y) +
        self.position.x
    local rotatedY = math.sin(self.rotation) * (x - self.position.x) + math.cos(self.rotation) * (y - self.position.y) +
        self.position.y

    return rotatedX > -halfWidth and rotatedX < halfWidth and rotatedY > -halfHeight and rotatedY < halfHeight
end

function Camera:screenToWorld(x, y)
    -- x, y are in screen coordinates. Returns x, y in world coordinates
    -- takes into account camera position, scale (getFovScale) and rotation

    local halfWidth = love.graphics.getWidth() / 2
    local halfHeight = love.graphics.getHeight() / 2

    local rotatedX = (x - halfWidth) / self.game.UnitSize / self:getFovScale()
    local rotatedY = (y - halfHeight) / self.game.UnitSize / self:getFovScale()

    local worldX = math.cos(self.rotation) * rotatedX - math.sin(self.rotation) * rotatedY + self.position.x
    local worldY = math.sin(self.rotation) * rotatedX + math.cos(self.rotation) * rotatedY + self.position.y

    return worldX, worldY
end

function Camera:worldToScreen(x, y)
    -- x, y are in world coordinates. Returns x, y in screen coordinates
    -- takes into account camera position, scale (getFovScale) and rotation

    local halfWidth = love.graphics.getWidth() / 2
    local halfHeight = love.graphics.getHeight() / 2

    local rotatedX = math.cos(-self.rotation) * (x - self.position.x) - math.sin(-self.rotation) * (y - self.position.y)
    local rotatedY = math.sin(-self.rotation) * (x - self.position.x) + math.cos(-self.rotation) * (y - self.position.y)

    local screenX = rotatedX * self.game.UnitSize * self:getFovScale() + halfWidth
    local screenY = rotatedY * self.game.UnitSize * self:getFovScale() + halfHeight

    return screenX, screenY
end

return Camera
