local tablef = {}

function tablef.copy(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
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

function tablef.eq(t1, t2)
    local t1keys = {}
    for k, v in pairs(t1) do
        t1keys[k] = true
    end

    for k, v in pairs(t2) do
        if not t1keys[k] then
            return false
        end
    end

    for k, v in pairs(t1) do
        if t1[k] ~= t2[k] then
            return false
        end
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
