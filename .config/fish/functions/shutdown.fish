function shutdown --description 'Linux-style shutdown for macOS'
    # Emulates the systemd `shutdown` interface on top of macOS /sbin/shutdown.
    #
    #   shutdown [OPTIONS] [TIME] [WALL_MESSAGE...]
    #
    # OPTIONS
    #   -r, --reboot      reboot the machine
    #   -H, --halt        halt the machine
    #   -P, --poweroff    power off the machine (default)
    #   -h                power off (combine with -H to halt)
    #   -k                dry run: don't actually shut down
    #   -c, --cancel      cancel a pending shutdown
    #       --no-wall     ignored
    #
    # TIME
    #   now         immediately
    #   +m          in m minutes
    #   hh:mm       at the given wall-clock time (today, or tomorrow if past)
    #   (omitted)   +1  (one minute)

    set -l action poweroff
    set -l time ''
    set -l cancel 0
    set -l dry 0
    set -l wall

    for arg in $argv
        switch $arg
            case -r --reboot
                set action reboot
            case -H --halt
                set action halt
            case -P --poweroff -h
                set action poweroff
            case -c --cancel
                set cancel 1
            case -k
                set dry 1
            case --no-wall --no-wtmp --no-sync -q --quiet
                # accepted, ignored
            case --help
                echo "Usage: shutdown [-rHPhkc] [TIME] [WALL_MESSAGE...]"
                echo "  TIME: now | +m | hh:mm  (default +1)"
                return 0
            case '--*' '-*'
                echo "shutdown: ignoring unknown option '$arg'" >&2
            case '*'
                if test -z "$time"
                    set time $arg
                else
                    set wall $wall $arg
                end
        end
    end

    # --- cancel a pending shutdown -----------------------------------------
    if test $cancel -eq 1
        if sudo pkill -x shutdown 2>/dev/null
            echo "Scheduled shutdown cancelled."
        else
            echo "No scheduled shutdown to cancel."
        end
        return 0
    end

    # --- map action to a macOS /sbin/shutdown flag -------------------------
    set -l flag -h
    if test "$action" = reboot
        set flag -r
    end

    # --- resolve the requested time ----------------------------------------
    test -z "$time"; and set time +1

    set -l now (date +%s)
    set -l target

    switch $time
        case now +0
            set target $now
        case '+*'
            set -l mins (string sub -s 2 -- $time)
            if not string match -qr '^[0-9]+$' -- $mins
                echo "shutdown: invalid time '$time'" >&2
                return 1
            end
            set target (math $now + $mins x 60)
        case '*:*'
            set target (date -d "$time" +%s 2>/dev/null)
            if test -z "$target"
                echo "shutdown: invalid time '$time'" >&2
                return 1
            end
            # If that clock time already passed today, schedule tomorrow.
            test $target -le $now; and set target (math $target + 86400)
        case '*'
            if string match -qr '^[0-9]+$' -- $time
                set target (math $now + $time x 60)
            else
                echo "shutdown: invalid time '$time'" >&2
                return 1
            end
    end

    # --- immediate ----------------------------------------------------------
    if test $target -le $now
        if test $dry -eq 1
            echo "shutdown: dry run, would $action now"
            return 0
        end
        sudo /sbin/shutdown $flag now $wall
        return $status
    end

    # --- scheduled: return immediately, run in background, cancellable ------
    set -l when (date -d "@$target" '+%a %Y-%m-%d %H:%M:%S')
    echo "Shutdown scheduled for $when, use 'shutdown -c' to cancel."
    test $dry -eq 1; and return 0

    set -l mtime (date -d "@$target" +%y%m%d%H%M)
    sudo -v; or return 1
    sudo /sbin/shutdown $flag $mtime $wall >/dev/null 2>&1 &
    disown
end
