local settings = require("settings")
local colors = require("colors")

-- LAN IPv4 address of the active interface.
local ip = sbar.add("item", "center.ipaddr", {
    position = "center",
    label = {
        string = "...",
        color = colors.white,
        padding_left = 2,
        padding_right = 6,
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 12.0,
        },
    },
    update_freq = 30,
    updates = true,
})

local function update()
    sbar.exec("ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null", function(out)
        local addr = out:gsub("%s+", "")
        if addr ~= "" then
            ip:set({
                label = { string = addr },
                icon = { color = colors.accent },
            })
        else
            ip:set({
                label = { string = "no ip" },
                icon = { color = colors.with_alpha(colors.accent, 0.4) },
            })
        end
    end)
end

ip:subscribe({ "routine", "system_woke", "forced", "wifi_change" }, update)
update()
