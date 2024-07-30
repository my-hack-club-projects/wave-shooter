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

return Instance
