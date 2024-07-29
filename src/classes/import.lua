return function(modules, path)
    if not path then
        path = modules
        modules = nil
    end

    local allModules = require(path)

    if not modules then
        return allModules
    end

    local result = {}

    for i, module in ipairs(modules) do
        assert(allModules[module] ~= nil, "Module " .. module .. " not found in " .. path)

        table.insert(result, allModules[module])
    end

    return unpack(result)
end
