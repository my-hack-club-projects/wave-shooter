local oo = require 'libs.oo'

local Instance = oo.class()

function Instance:init()
    self.children = {}
end

function Instance:addChild(class)
    local child = class()
    child.parent = self
    table.insert(self.children, child)

    return child
end

function Instance:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            return
        end
    end
end

function Instance:findFirstChild(name)
    for i, child in ipairs(self.children) do
        if child.name == name then
            return child
        end
    end
end

function Instance:getChildren()
    return self.children
end

function Instance:clearAllChildren()
    self.children = {}
end

return Instance
