local M = {}

local function char_width(cp)
    if
        (cp >= 0x1100 and cp <= 0x115F) -- Hangul Jamo
        or (cp >= 0x2E80 and cp <= 0x303E) -- CJK radicals, Kangxi, punctuation
        or (cp >= 0x3041 and cp <= 0x33FF) -- Hiragana, Katakana, CJK symbols
        or (cp >= 0x3400 and cp <= 0x4DBF) -- CJK Ext A
        or (cp >= 0x4E00 and cp <= 0x9FFF) -- CJK Unified
        or (cp >= 0xA000 and cp <= 0xA4CF) -- Yi
        or (cp >= 0xAC00 and cp <= 0xD7A3) -- Hangul syllables
        or (cp >= 0xF900 and cp <= 0xFAFF) -- CJK compatibility
        or (cp >= 0xFE30 and cp <= 0xFE4F) -- CJK compatibility forms
        or (cp >= 0xFF00 and cp <= 0xFF60) -- Fullwidth forms
        or (cp >= 0xFFE0 and cp <= 0xFFE6) -- Fullwidth signs
        or (cp >= 0x20000 and cp <= 0x3FFFD) -- CJK Ext B+
    then
        return 2
    end
    return 1
end

function M.width(s)
    local w = 0
    for _, cp in utf8.codes(s) do
        w = w + char_width(cp)
    end
    return w
end

-- Truncate to at most n display columns, reserving one column for the ellipsis.
function M.truncate(s, n)
    if M.width(s) <= n then
        return s
    end
    local budget = n - 1
    local w = 0
    local out = {}
    for _, cp in utf8.codes(s) do
        local cw = char_width(cp)
        if w + cw > budget then
            break
        end
        w = w + cw
        out[#out + 1] = utf8.char(cp)
    end
    return table.concat(out) .. "…"
end

-- Pad to n display columns with EM SPACE (U+2003, invisible, ~"M"-wide) so a
-- short title still holds the pill width and it stops shifting.
local PAD_CHAR = "\xe2\x80\x83"
function M.pad_to(s, n)
    local w = M.width(s)
    if w < n then
        return s .. string.rep(PAD_CHAR, n - w)
    end
    return s
end

return M
