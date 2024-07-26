local mathf = setmetatable({}, { __index = math })

function mathf.clamp(value, min, max)
    assert(value and min and max, "All arguments must be provided")

    if min > max then min, max = max, min end
    return math.min(math.max(value, min), max)
end

function mathf.lerp(a, b, t)
    assert(a and b and t, "All arguments must be provided")

    return a + (b - a) * t
end

function mathf.approach(current, target, maxDelta)
    assert(current and target and maxDelta, "All arguments must be provided")

    return current + mathf.clamp(target - current, -maxDelta, maxDelta)
end

function mathf.round(value)
    assert(value, "Value must be provided")

    return math.floor(value + 0.5)
end

function mathf.sign(value)
    assert(value, "Value must be provided")

    return value > 0 and 1 or value < 0 and -1 or 0
end

function mathf.distance(x1, y1, x2, y2)
    assert(x1 and y1 and x2 and y2, "All arguments must be provided")

    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function mathf.angle(x1, y1, x2, y2)
    assert(x1 and y1 and x2 and y2, "All arguments must be provided")

    return math.atan(y2 - y1, x2 - x1)
end

return mathf
