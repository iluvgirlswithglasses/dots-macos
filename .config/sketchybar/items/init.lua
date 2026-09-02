local colors = require("colors")

-- left side: icon, workspaces manager, media manager
require("items.apple")
require("items.spaces")

-- middle: the weird ass webcam spot
require("items.media")
sbar.add("item", "center.notch", {
    position = "center",
    width = 200,
    icon = { drawing = false },
    label = { drawing = false },
    background = { color = colors.transparent },
})
require("items.ipaddr")
require("items.calendar")

-- rightside: utils display
require("items.widgets.battery")
require("items.widgets.volume")
require("items.widgets.wifi")

-- draw brackets after widgets are created
CORNER_RADIUS = 8

sbar.add("bracket", "bracket.left", { "apple.logo", "/space\\..*/", "spaces.right_pad" }, {
    background = {
        color = colors.bg1,
        corner_radius = CORNER_RADIUS,
        height = 28,
        border_width = 0,
    },
})

sbar.add("bracket", "bracket.media", {
    "/^center\\.media.*/",
    "center.notch",
    "center.ipaddr",
    "center.time",
    "center.date",
}, {
    background = {
        color = colors.bg3,
        corner_radius = CORNER_RADIUS,
        height = 24,
        border_width = 0,
    },
})

sbar.add("bracket", "bracket.right", {
    "widgets.wifi",
    "widgets.volume",
    "widgets.battery",
}, {
    background = {
        color = colors.bg1,
        corner_radius = CORNER_RADIUS,
        height = 28,
        border_width = 0,
    },
})
