local oo = require 'libs.oo'
local import = require 'classes.import'
local mathf = require 'classes.mathf'
local tablef = require 'classes.tablef'
local Vector2 = require 'types.vector2'
local UDim2 = require 'types.udim2'
local Color4 = require 'types.color4'

local WorldUI, Frame = import({ 'WorldUI', 'Frame' }, 'classes.ui')

local Character = require 'classes.character'
local Bullet = require 'classes.bullet'

local Player = oo.class(Character)

function Player:init(props)
    Character.init(self, props)

    assert(props.camera, "Player requires a camera")

    self.name = "Player"
    self.camera = props.camera

    self.image = love.graphics.newImage("assets/images/player2.png")
    self.scaleAxis = "y"
    self.size = Vector2(1.5, 1.5)
    self.autoAimMagnitude = props.autoAimMagnitude or 1

    self:chooseShotType("Default")

    self.prevTarget = nil
    self.lastTarget = nil
    self.targetDuration = 1 -- to prevent from being visible at the start

    self.targetUIInitialSize = Vector2(4, 4)
    self.targetUITargetSizeOffset = Vector2(1, 1)
    self.targetUITargetDuration = 0.05
    self.targetUIColor = Color4(1, 1, 1, 1)
    self.targetUIFrames = {}

    self.targetHighlightUI = WorldUI(self.game)
    self.targetHighlightUI.size = Vector2(1, 1)

    local container = self.targetHighlightUI:addChild(Frame)
    container.size = UDim2(2, 0, 2, 0)
    container.color = Color4(0, 0, 0, 0)

    local cornerFrameThickness = 0.1
    local cornerFrameLength = 0.3

    for i = 1, 4 do
        local cornerFrame1 = container:addChild(Frame)
        cornerFrame1.size = UDim2(cornerFrameThickness, 0, cornerFrameLength, 0)
        cornerFrame1.position = UDim2(i % 2, 0, i <= 2 and 0 or 1, 0)
        cornerFrame1.anchorPoint = Vector2(i % 2, i <= 2 and 0 or 1)

        local cornerFrame2 = container:addChild(Frame)
        cornerFrame2.size = UDim2(cornerFrameLength, 0, cornerFrameThickness, 0)
        cornerFrame2.position = UDim2(i % 2, 0, i <= 2 and 0 or 1, 0)
        cornerFrame2.anchorPoint = Vector2(i % 2, i <= 2 and 0 or 1)

        table.insert(self.targetUIFrames, cornerFrame1)
        table.insert(self.targetUIFrames, cornerFrame2)
    end
end

function Player:getDirection()
    return Vector2(
        love.keyboard.isDown("d") and 1 or love.keyboard.isDown("a") and -1 or 0,
        love.keyboard.isDown("s") and 1 or love.keyboard.isDown("w") and -1 or 0
    )
end

function Player:updateCamera(dt)
    local cameraPosition = self.camera.position
    local playerPosition = self.position

    local distance = (playerPosition - cameraPosition).magnitude
    local direction = distance > 0 and (playerPosition - cameraPosition).unit or Vector2(0, 0)

    local speed = (distance ^ 2) / 2 -- Quadratic easing

    self.camera.position = cameraPosition + direction * speed * dt
end

function Player:update(dt)
    Character.update(self, dt)

    local mouseWorldPosition = Vector2(self.camera:screenToWorld(love.mouse.getPosition()))

    -- Aim (aim assist / locking)
    local allEnemies = self.game.current.entity.findAll("Enemy")
    local closest, closestDistance = nil, math.huge
    for _, enemy in ipairs(allEnemies) do
        local distance = (enemy.position - mouseWorldPosition).magnitude - enemy.size.magnitude / 2

        if distance < self.autoAimMagnitude and distance < closestDistance then
            closest = enemy
            closestDistance = distance
        end
    end

    if closest then
        mouseWorldPosition = closest.position
        self.lastTarget = closest
    end

    self.aimDirection = (mouseWorldPosition - self.position).unit
    self.rotation = math.atan2(self.aimDirection.y, self.aimDirection.x)

    -- Fire
    if love.mouse.isDown(1) and love.timer.getTime() - self.lastFired > 1 / self.fireRate then
        self.lastFired = love.timer.getTime()
        self:fire()
    end

    for _, bullet in ipairs(self.bullets) do
        bullet:checkCollision(allEnemies)
    end

    self:updateCamera(dt)

    local function getSizeForEntity(entity)
        return entity.size + self.targetUITargetSizeOffset
    end

    self.targetHighlightUI.position = self.lastTarget and self.lastTarget.position or Vector2(0, 0)
    self.targetHighlightUI.size = mathf.lerp(
        closest and self.targetUIInitialSize or
        (self.lastTarget and getSizeForEntity(self.lastTarget) or self.targetUIInitialSize),
        closest and getSizeForEntity(closest) or self.targetUIInitialSize,
        mathf.clamp(self.targetDuration / self.targetUITargetDuration, 0, 1)
    )

    local t = closest and self.targetDuration / self.targetUITargetDuration or
        1 - self.targetDuration / self.targetUITargetDuration
    local opacity = mathf.clamp(t, 0, 1)
    local color = Color4(
        self.targetUIColor.r,
        self.targetUIColor.g,
        self.targetUIColor.b,
        self.targetUIColor.a * opacity
    )

    for _, frame in ipairs(self.targetUIFrames) do
        frame.color = color
    end

    self.targetHighlightUI:update(dt)

    self.targetDuration = self.targetDuration + dt

    if self.prevTarget ~= closest then
        self.prevTarget = closest

        if self.targetDuration >= self.targetUITargetDuration then
            self.targetDuration = 0
        else
            self.targetDuration = self.targetUITargetDuration - self.targetDuration
        end
    end
end

function Player:draw()
    Character.draw(self)

    self.targetHighlightUI:draw()
end

return Player
