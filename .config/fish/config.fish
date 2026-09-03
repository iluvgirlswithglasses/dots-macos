
######################################################################
#### --------------------- system variables --------------------- ####
######################################################################

set -x PATH /opt/homebrew/opt/coreutils/libexec/gnubin $PATH /usr/sbin ~/.local/bin

abbr --add cloneme git clone ssh+git://git@github.com/iluvgirlswithglasses/
abbr --add setntp timedatectl set-ntp
abbr --add settime sudo timedatectl set-time


######################################################################
#### ------------------------- aliases -------------------------- ####
######################################################################

alias py="python3"
alias vim="nvim"
alias cin="cat"
alias q="exit"
alias :q="exit"
alias clip="pbcopy"


######################################################################
#### ---------------------- quick actions ----------------------- ####
######################################################################

function yd
    pwd | tr -d '\n' | pbcopy;
end

function rundisown
    echo $argv[1..]
    $argv[1..] 2> /dev/null &
    set PID (jobs --last --pid)
    disown $PID
end


######################################################################
#### --------------------- terminal config ---------------------- ####
######################################################################

function fish_prompt -d "Write out the prompt"
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

function postexec_test --on-event fish_postexec
   echo
end

if status is-interactive
    set fish_greeting
    # This sleep is for MacOS Ghostty only
    sleep 0.1
    macchina
end

# starship init fish | source
if test -f ~/.cache/ags/user/generated/terminal/sequences.txt
    cat ~/.cache/ags/user/generated/terminal/sequences.txt
end

fish_config prompt choose pythonista

