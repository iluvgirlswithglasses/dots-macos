local colors = require("colors")

sbar.bar({
    topmost = "window",
    height = 31,
    color = colors.bar.bg,
    border_width = 0, -- set to 1 to make border_color visible
    border_color = colors.bar.border,
    blur_radius = colors.bar.blur,
    shadow = true,
    position = "top",
    sticky = true,
    padding_right = 0,
    padding_left = 0,
    y_offset = 8,
    margin = 10,
    corner_radius = 8,
})
