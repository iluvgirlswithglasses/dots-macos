local colors = require("colors")

sbar.add("item", "apple.logo", {
    position = "left",
    background = {
        image = {
            string = os.getenv("HOME") .. "/.config/sketchybar/assets/blossom.png",
            scale = 0.04,
        },
    },
    label = { drawing = false },
    padding_left = 20,
    padding_right = 5,
})

sbar.add("item", {
    position = "left",
    width = 10,
    icon = {
        string = "|",
        font = { size = 16.0 },
        y_offset = 1,
        color = colors.with_alpha(colors.white, 0.3),
    },
})
