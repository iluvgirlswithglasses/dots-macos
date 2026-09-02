-- the slopiest script ever written in history of programming

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local text = require("helpers.text")

local function icon_font(size)
    return { family = settings.font.icons, style = settings.font.style_map["Bold"], size = size }
end
local function text_font(size)
    return { family = settings.font.text, style = settings.font.style_map["Bold"], size = size }
end
local function accent(a)
    return colors.with_alpha(colors.accent, a)
end

local function transport(name, position, glyph, size, color, pad_l, pad_r, cmd)
    return sbar.add("item", name, {
        position = position,
        icon = {
            string = glyph,
            font = icon_font(size),
            color = color,
            padding_left = pad_l,
            padding_right = pad_r,
        },
        label = { drawing = false },
        click_script = cmd,
    })
end

local playpause =
    transport("center.media.playpause", "center", icons.media.play, 13, accent(0.45), 4, 4, "nowplaying-cli togglePlayPause")

local artwork = sbar.add("item", "center.media.artwork", {
    position = "center",
    background = {
        image = { string = "", scale = 0.23, corner_radius = 4 },
        color = colors.transparent,
        border_width = 0,
        height = 22,
        corner_radius = 4,
    },
    icon = { drawing = false },
    label = { drawing = false },
    drawing = false,
    padding_left = 4,
    padding_right = 2,
})

local media = sbar.add("item", "center.media", {
    position = "center",
    icon = { drawing = false },
    scroll_texts = false,
    label = {
        string = "Waiting for media manager...",
        font = text_font(12),
        color = colors.white,
        padding_left = 4,
        padding_right = 4,
    },
    popup = {
        align = "center",
        horizontal = true,
        background = {
            color = colors.popup.bg,
            corner_radius = 9,
            border_width = 1,
            border_color = colors.popup.border,
            height = 56,
        },
    },
    update_freq = 1,
    updates = true,
})

local popup_artwork = sbar.add("item", "popup.center.media.art", {
    position = "popup.center.media",
    background = {
        image = { string = "", scale = 0.5, corner_radius = 6 },
        color = colors.transparent,
        border_width = 0,
        height = 48,
        corner_radius = 6,
    },
    icon = { drawing = false },
    label = { drawing = false },
    drawing = false,
    padding_left = 10,
    padding_right = 6,
})

local popup_title = sbar.add("item", "popup.center.media.title", {
    position = "popup.center.media",
    icon = { drawing = false },
    label = { string = "", font = text_font(13), color = 0xffffffff, padding_left = 4, padding_right = 4 },
})

local popup_artist = sbar.add("item", "popup.center.media.artist", {
    position = "popup.center.media",
    icon = { drawing = false },
    label = { string = "", font = text_font(12), color = colors.with_alpha(colors.white, 0.55), padding_left = 2, padding_right = 10 },
})

local popup_prev =
    transport("popup.center.media.prev", "popup.center.media", icons.media.back, 14, accent(0.85), 12, 8, "nowplaying-cli previous")
local popup_playpause =
    transport("popup.center.media.playpause", "popup.center.media", icons.media.play, 14, colors.accent, 8, 8, "nowplaying-cli togglePlayPause")
local popup_next =
    transport("popup.center.media.next", "popup.center.media", icons.media.forward, 14, accent(0.85), 8, 12, "nowplaying-cli next")

-- write artwork to disk then load on demand
os.execute("rm -f /tmp/sketchybar_art_*.jpg 2>/dev/null")
local ART_SLOTS = { "/tmp/sketchybar_art_a.jpg", "/tmp/sketchybar_art_b.jpg" }
local art_slot = 0

local SHOW_ARTWORK = true
local MAX_LABEL_CHARS = SHOW_ARTWORK and 20 or 24

local current_track_key = nil
local last_label_state = nil
local last_play_state = nil

local function set_artwork(path)
    if SHOW_ARTWORK then
        artwork:set({
            drawing = true,
            background = { image = { drawing = true, string = path } },
            icon = { drawing = false },
        })
    end
    popup_artwork:set({ drawing = true, background = { image = { drawing = true, string = path } } })
end

local function hide_artwork()
    artwork:set({ drawing = false })
    popup_artwork:set({ drawing = false })
end

local function show_idle_artwork()
    if not SHOW_ARTWORK then
        artwork:set({ drawing = false })
        return
    end
    artwork:set({
        drawing = true,
        background = { image = { drawing = false } },
        icon = {
            drawing = true,
            string = ":music:",
            font = { family = "sketchybar-app-font", style = "Regular", size = 14.0 },
            color = accent(0.45),
            padding_left = 4,
            padding_right = 4,
        },
    })
end

local function show_track(title, artist)
    local key = (title or "") .. "|" .. (artist or "")
    if key == current_track_key then
        return
    end
    current_track_key = key

    popup_title:set({ label = { string = title or "" } })
    popup_artist:set({ label = { string = artist or "" } })

    art_slot = art_slot % #ART_SLOTS + 1
    local path = ART_SLOTS[art_slot]
    local cmd = string.format(
        "nowplaying-cli get artworkData 2>/dev/null | base64 -D > %q 2>/dev/null; "
            .. "if [ -s %q ]; then sips -Z 96 %q >/dev/null 2>&1; echo ok; else rm -f %q; fi",
        path,
        path,
        path,
        path
    )
    sbar.exec(cmd, function(out)
        if current_track_key ~= key then
            return
        end
        if out and out:match("ok") then
            set_artwork(path)
        else
            hide_artwork()
        end
    end)
end

local function reset_media()
    current_track_key = nil
    show_idle_artwork()
    popup_artwork:set({ drawing = false })
    popup_title:set({ label = { string = "" } })
    popup_artist:set({ label = { string = "" } })
end

local function set_play_icon(playing)
    if playing == last_play_state then
        return
    end
    last_play_state = playing
    local glyph = playing and icons.media.pause or icons.media.play
    local color = playing and colors.accent or accent(0.45)
    playpause:set({ icon = { string = glyph, color = color } })
    popup_playpause:set({ icon = { string = glyph } })
end

local function set_label(text_str, faded, animate)
    text_str = text.pad_to(text_str, MAX_LABEL_CHARS)
    local key = (faded and "f|" or "n|") .. text_str
    if key == last_label_state then
        return
    end
    last_label_state = key
    local color = faded and colors.with_alpha(colors.white, faded) or 0xffffffff
    if animate then
        sbar.animate("tanh", 10, function()
            media:set({ label = { string = text_str, color = color } })
        end)
    else
        media:set({ label = { string = text_str, color = color } })
    end
end

local function set_idle()
    reset_media()
    set_play_icon(false)
    set_label("It's pretty silent in here...", 0.5, true)
end

local function set_track(title, artist, playing)
    local display = text.truncate(title .. (artist ~= "" and (" – " .. artist) or ""), MAX_LABEL_CHARS)
    show_track(title, artist)
    set_play_icon(playing)
    set_label(display, not playing and 0.5 or false, true)
end

local function poll()
    sbar.exec("nowplaying-cli get playbackRate title artist", function(out)
        local rate_str, title, artist = out:match("([^\n]*)\n([^\n]*)\n([^\n]*)")
        local rate = tonumber(rate_str) or 0
        title = title and title:gsub("^%s*(.-)%s*$", "%1") or ""
        artist = artist and artist:gsub("^%s*(.-)%s*$", "%1") or ""

        if title ~= "" and title ~= "null" then
            set_track(title, artist, rate > 0)
        else
            set_idle()
        end
    end)
end

local function poll_after(cmd)
    sbar.exec(cmd, function()
        poll()
        sbar.exec("sleep 0.4 && true", function()
            poll()
        end)
    end)
end

local function toggle_popup()
    media:set({ popup = { drawing = "toggle" } })
end

local function optimistic_toggle()
    if last_play_state ~= nil then
        local now_playing = not last_play_state
        set_play_icon(now_playing)
        if last_label_state then
            local text_str = last_label_state:sub(3)
            last_label_state = nil
            set_label(text_str, not now_playing and 0.45 or false, false)
        end
    end
    poll_after("nowplaying-cli togglePlayPause")
end

media:subscribe({ "routine", "system_woke", "media_change" }, poll)
media:subscribe("mouse.clicked", toggle_popup)
artwork:subscribe("mouse.clicked", toggle_popup)
playpause:subscribe("mouse.clicked", optimistic_toggle)
popup_playpause:subscribe("mouse.clicked", optimistic_toggle)
popup_prev:subscribe("mouse.clicked", function()
    poll_after("nowplaying-cli previous")
end)
popup_next:subscribe("mouse.clicked", function()
    poll_after("nowplaying-cli next")
end)
media:subscribe("mouse.exited.global", function()
    media:set({ popup = { drawing = false } })
end)

poll()
