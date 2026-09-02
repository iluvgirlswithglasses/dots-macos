-- teto theme
local theme = {
    base = 0xff0a0606,
    surface = 0xff140a0a,
    overlay = 0xff1f1414,
    muted = 0xff5a3030,
    subtle = 0xff8a5050,
    text = 0xfff5ebe0,
    love = 0xffe63946,
    gold = 0xfff4c95d,
    rose = 0xffe85a6e,
    pine = 0xff4ec6e0,
    foam = 0xff7ddfff,
    iris = 0xffd97aaa,
    highlight_low = 0xff080404,
    highlight_med = 0xff1a0e0e,
    highlight_high = 0xff2a1414,

    black = 0xff0a0606,
    white = 0xfff5ebe0,
    red = 0xffe63946,
    green = 0xff8ac35a,
    blue = 0xff4ec6e0,
    yellow = 0xfff4c95d,
    orange = 0xffe87655,
    magenta = 0xffd97aaa,
    grey = 0xff5a3030,
    transparent = 0x00000000,
    accent = 0xffe63946,

    bar = { bg = 0xff000000, border = 0xff2a1414, blur = 0 },
    popup = { bg = 0xff0a0606, border = 0xffe63946 },
    space_active = 0xff5c1019,
    space_active_fg = 0xfff5ebe0,
    bg1 = 0x00000000,
    bg2 = 0xff200a0a,
    bg3 = 0xff2a0a0a,
}

theme.with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
        return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return theme
