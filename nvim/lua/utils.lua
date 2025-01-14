local M = {}

function M.hexToRgb(c)
    c = string.lower(c)
    return {
        tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16),
        tonumber(c:sub(6, 7), 16)
    }
end

function M.blendColors(foreground, background, alpha)
    alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
    local bg = M.hexToRgb(background or "#000000")
    local fg = M.hexToRgb(foreground or "#ffffff")

    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2),
                         blendChannel(3))
end

return M
