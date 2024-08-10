local _unpack = unpack or table.unpack

local tablef = {}

function tablef.unpack(t)
    return _unpack(t)
end

function tablef.copy(t)
    local new = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            new[k] = tablef.copy(v)
        else
            new[k] = v
        end
    end
    return new
end

function tablef.clear(t)
    for k, v in pairs(t) do
        t[k] = nil
    end
end

function tablef.find(t, f)
    -- for i, v in ipairs(t) do -- TODO: Use pairs for non-integer keys
    --     if f(v) then
    --         return i
    --     end
    -- end
    -- return nil

    for k, v in pairs(t) do
        if f(v) then
            return k
        end
    end
end

function tablef.eq(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or tablef.eq(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function tablef.random(t)
    return t[math.random(#t)]
end

function tablef.values(t)
    local values = {}
    for k, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

return tablef
