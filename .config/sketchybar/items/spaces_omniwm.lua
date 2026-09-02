-- OmniWM backend for spaces.lua.

local M = {}

M.events = { "omniwm_workspace_changed", "front_app_switched" }

local PIDFILE = "/tmp/sketchybar_omniwm_watch.pid"
local WATCH_CMD = "omniwmctl watch active-workspace,windows-changed "
    .. "--exec sketchybar --trigger omniwm_workspace_changed"
local LAUNCH = "(" .. WATCH_CMD .. " >/dev/null 2>&1 & echo $! > " .. PIDFILE .. ")"

-- Reload watchers
os.execute("pkill -f 'omniwmctl[ ]watch' 2>/dev/null")
os.execute(LAUNCH)

function M.ensure_watcher()
    sbar.exec(
        'ps -p "$(cat ' .. PIDFILE .. ' 2>/dev/null)" -o command= 2>/dev/null '
            .. "| grep -q omniwmctl || "
            .. LAUNCH
    )
end

function M.fetch_state_cmd()
    return [[omniwmctl query windows | jq -r '.result.payload.windows[] | select(.workspace != null) | .workspace.rawName' && echo '---' && omniwmctl query workspaces | jq -r '.result.payload.workspaces[].rawName' && echo '---' && omniwmctl query active-workspace | jq -r '.result.payload.workspace.rawName']]
end

function M.click_cmd(workspace_id)
    return 'omniwmctl workspace focus-name "' .. workspace_id .. '"'
end

return M
