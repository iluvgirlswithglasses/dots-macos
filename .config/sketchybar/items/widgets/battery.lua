local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
    position = "right",
    icon = {
        font = {
            style = settings.font.style_map["Bold"],
            size = 14.0,
        },
        padding_left = 8,
        padding_right = 4,
    },
    label = {
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 12.0,
        },
        color = colors.white,
        padding_right = 10,
    },
    update_freq = 30,
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
    sbar.exec("pmset -g batt", function(batt_info)
        local icon = "!"
        local label = "?"

        local found, _, charge = batt_info:find("(%d+)%%")
        if found then
            charge = tonumber(charge)
            label = charge .. "%"
        end

        local charging = batt_info:find("AC Power")

        local color
        if charging then
            icon = icons.battery.charging
            color = colors.blue
        elseif found and charge > 60 then
            icon = icons.battery._100
            color = colors.green
        elseif found and charge > 40 then
            icon = icons.battery._75
            color = colors.gold
        elseif found and charge > 20 then
            icon = icons.battery._50
            color = colors.orange
        elseif found and charge > 10 then
            icon = icons.battery._25
            color = colors.orange
        else
            icon = icons.battery._0
            color = colors.red
        end

        local lead = (found and charge < 10) and "0" or ""

        battery:set({
            icon = { string = icon, color = color },
            label = { string = lead .. label },
        })
    end)
end)
