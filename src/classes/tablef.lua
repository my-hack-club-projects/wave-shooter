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
    for i, v in ipairs(t) do
        if f(v) then
            return i
        end
    end
    return nil
end

return tablef
