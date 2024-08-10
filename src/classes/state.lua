local oo = require 'libs.oo'

local State = oo.class()

function State:init(game)
    assert(game, "State must be initialized with a game object")

    self.data = {}
    self.name = "BaseState"
    self.game = game
    self.prevState = nil
    self.camera = nil

    local function sortEntities(a, b)
        return a.zindex < b.zindex
    end

    self.entity = {
        new = function(entityClass, ...)
            local props = ...

            if not props["game"] then
                props["game"] = self.game
            end

            local entity = entityClass(...)

            table.insert(self._entities, entity)
            entity.state = self

            table.sort(self._entities, sortEntities)

            return entity
        end,

        insert = function(entity)
            table.insert(self._entities, entity)
            entity.state = self

            table.sort(self._entities, sortEntities)
        end,

        find = function(name)
            for i, entity in ipairs(self._entities) do
                if entity.name == name then
                    return entity
                end
            end
        end,

        findAll = function(name)
            local entities = {}
            for i, entity in ipairs(self._entities) do
                if entity.name == name then
                    table.insert(entities, entity)
                end
            end
            return entities
        end,

        remove = function(entity)
            for i, e in ipairs(self._entities) do
                if e == entity then
                    table.remove(self._entities, i)
                    table.sort(self._entities, sortEntities)

                    return
                end
            end
        end,

        getAll = function()
            return self._entities
        end
    }

    self._entities = {}
end

function State:enter(prevState)
    -- To be overwritten by a subclass
end

function State:exit()
    for i, entity in ipairs(self._entities) do
        entity:destroy()
    end

    self._entities = {}
end

function State:update(dt)
    for i, entity in ipairs(self._entities) do
        entity:update(dt, self._entities)
    end
end

function State:draw()
    if self.camera then
        self.camera:attach()
    end

    for i, entity in ipairs(self._entities) do
        entity:draw(self.game.UnitSize)
    end

    if self.camera then
        self.camera:detach()
    end
end

function State:__tostring()
    return "<StateObject " .. self.name .. ">"
end

return State
