local colors = require("colors")
local settings = require("settings")
local wm = require("items.spaces_omniwm")

local MAX_SLOTS = 10
local SLOT_HEIGHT = 24
local REFRESH_INTERVAL = 5
local WATCHER_CHECK_INTERVAL = 30
local REFRESH_LOCK = 3

-- One fixed pool of slots, built once at config load. Workspaces are mapped onto
-- slots each refresh.
-- pool[i] = { item = <sbar item>, ws = <id|nil>, key = <visual-state string|nil> }
local pool = {}

-- Refreshes are async; if one is asked for while another is in flight, coalesce
-- into a single trailing run.
local refresh_at = 0
local refresh_pending = false

-- Cache three states of a slot to skip sbar writes.
local function state_key(active, occupied)
    return active and "active" or (occupied and "occupied" or "empty")
end

local function slot_props(active, occupied, label)
    local bg = active and colors.space_active or (occupied and colors.bg3 or 0xff000000)
    return {
        drawing = true,
        label = { string = "", drawing = false, padding_left = 0, padding_right = 0 },
        icon = {
            string = label,
            color = colors.space_active_fg,
            drawing = true,
            width = SLOT_HEIGHT,
            align = "center",
            padding_left = 0,
            padding_right = 0,
        },
        background = { color = bg },
    }
end

-- Split the backend's "---"-delimited output into: set of occupied workspaces,
-- ordered workspace list, focused id.
local function parse(output)
    local occupied, order, focused = {}, {}, ""
    local section = 1
    for line in output:gmatch("[^\n]+") do
        if line == "---" then
            section = section + 1
        elseif section == 1 then
            local ws = line:gsub("%s+", "")
            if ws ~= "" then
                occupied[ws] = true
            end
        elseif section == 2 then
            order[#order + 1] = line:gsub("%s+", "")
        else
            focused = line:gsub("%s+", "")
        end
    end
    return occupied, order, focused
end

local function refresh()
    local now = os.time()
    if refresh_at ~= 0 and (now - refresh_at) < REFRESH_LOCK then
        refresh_pending = true
        return
    end
    refresh_at = now

    sbar.exec(wm.fetch_state_cmd(), function(output)
        refresh_at = 0
        local occupied, order, focused = parse(output)

        -- A WM restart / IPC hiccup yields no workspaces; keep the current slots.
        if #order > 0 then
            local recolors = {}
            for i = 1, MAX_SLOTS do
                local slot = pool[i]
                local prev_ws = slot.ws
                local ws = order[i]

                if prev_ws ~= ws then
                    slot.ws = ws
                    slot.key = nil
                    if ws then
                        slot.item:set({ click_script = wm.click_cmd(ws) })
                    else
                        slot.item:set({ drawing = false })
                    end
                end

                if slot.ws then
                    local active = slot.ws == focused
                    local occ = occupied[slot.ws] == true
                    local key = state_key(active, occ)
                    if slot.key ~= key then
                        slot.key = key
                        local props = slot_props(active, occ, slot.ws)
                        if prev_ws == nil then
                            -- Just appeared: snap, so it doesn't animate up from bg2.
                            slot.item:set(props)
                        else
                            -- Existing slot: animate the recolor for a smooth swap.
                            local color = props.background.color
                            props.background = nil
                            slot.item:set(props)
                            recolors[#recolors + 1] = { item = slot.item, color = color }
                        end
                    end
                end
            end

            if #recolors > 0 then
                sbar.animate("tanh", 8, function()
                    for _, r in ipairs(recolors) do
                        r.item:set({ background = { color = r.color } })
                    end
                end)
            end
        end

        if refresh_pending then
            refresh_pending = false
            refresh()
        end
    end)
end

for i = 1, MAX_SLOTS do
    pool[i] = {
        ws = nil,
        key = nil,
        item = sbar.add("item", "space.slot." .. i, {
            icon = {
                font = { family = settings.font.text, style = settings.font.style_map["Bold"], size = 12 },
                string = "",
                color = colors.white,
                padding_left = 9,
                padding_right = 9,
                y_offset = 0,
                drawing = true,
            },
            label = {
                string = "",
                font = "sketchybar-app-font:Regular:14.0",
                color = colors.base,
                padding_left = 0,
                padding_right = 0,
                y_offset = -1,
                drawing = false,
            },
            background = {
                color = colors.bg2,
                corner_radius = math.ceil(SLOT_HEIGHT / 2),
                height = SLOT_HEIGHT,
            },
            padding_left = 6,
            padding_right = 0,
            drawing = false,
        }),
    }
end

-- Invisible spacer padding the right end of the spaces bracket.
sbar.add("item", "spaces.right_pad", {
    width = 0,
    icon = { drawing = false },
    label = { drawing = false },
    background = { drawing = false },
})

-- Hidden item whose only job is to drive refreshes on a timer and on WM events.
local driver = sbar.add("item", {
    drawing = false,
    updates = true,
    update_freq = REFRESH_INTERVAL,
})

local events = { "routine" }
for _, ev in ipairs(wm.events) do
    events[#events + 1] = ev
end

-- The push watcher dies when OmniWM restarts (its IPC token rotates); respawn it
-- if gone, throttled onto the refresh tick.
local last_watcher_check = os.time()
driver:subscribe(events, function()
    if wm.ensure_watcher then
        local now = os.time()
        if now - last_watcher_check >= WATCHER_CHECK_INTERVAL then
            last_watcher_check = now
            wm.ensure_watcher()
        end
    end
    refresh()
end)

refresh()
