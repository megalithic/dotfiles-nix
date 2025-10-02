#!/usr/local/bin/zsh

SESSION="launchdeck"
CWD="$CODE/work/cspire/$SESSION"

export SESSION_ICON="󱓞"
export SESSION_FG="#00b6f0"

cd $CWD

# if [ -f $CWD/development/scripts/setup_dev_ips.sh ]; then
#   source $CWD/development/scripts/setup_dev_ips.sh
# fi

# Create the session and the first window. Manually switch to root
# directory if required to support tmux < 1.9
tmux -2 new-session -d -s "$SESSION" -n comms
tmux -2 send-keys -t "$SESSION":1 cd\ "$CWD" C-m

# Create other windows.
tmux -2 new-window -c "$CWD" -t "$SESSION":2 -n code
tmux -2 new-window -c "$CWD" -t "$SESSION":3 -n agents
tmux -2 new-window -c "$CWD" -t "$SESSION":4 -n services

# COMMUNICATIONS
# tmux -2 send-keys -t "$SESSION":1 C-z "tmux link-window -s mega:chats -t 0 && exit" "C-m"

# MANUAL CODE MODE
tmux -2 send-keys -t "$SESSION":2.1 "cd ~/code/work/cspire/launchdeck" C-m
tmux -2 send-keys -t "$SESSION":2.1 "ls" C-m
tmux -2 select-layout -t "$SESSION":2 main-vertical
tmux -2 select-pane -t "$SESSION":2.1

# AI AGENTS and CLIENTS
tmux send-keys -t "$SESSION":3.1 "cd ~/code/work/cspire/launchdeck" C-m
tmux send-keys -t "$SESSION":3.1 "claude" C-m
tmux splitw -c "$CWD" -t "$SESSION":3
# tmux select-layout -t "$SESSION":3 tiled
tmux send-keys -t "$SESSION":3.2 "cd ~/code/work/cspire/launchdeck/launchdeck_portal" "C-m"
# tmux send-keys -t "$SESSION":3.2 "claude" C-m
tmux splitw -c "$CWD" -t "$SESSION":3.2
# tmux select-layout -t "$SESSION":3.2 tiled
tmux send-keys -t "$SESSION":3.3 "cd ~/code/work/cspire/launchdeck/launchdeck_portal_api" "C-m"
# tmux send-keys -t "$SESSION":3.3 "claude" C-m
# tmux select-layout -t "$SESSION":3 tiled
tmux select-layout -t "$SESSION":3 main-vertical
tmux select-pane -t "$SESSION":3.1

# PERSISTENT SERVICES
tmux send-keys -t "$SESSION":4.1 "cd ~/code/work/cspire/launchdeck/launchdeck_portal" C-m
# tmux send-keys -t "$SESSION":4.1 "devspace purge" C-m
tmux send-keys -t "$SESSION":4.1 "devspace dev -n smesser-dev" C-m
tmux splitw -c "$CWD" -t "$SESSION":4
tmux select-layout -t "$SESSION":4 even-horizontal
tmux send-keys -t "$SESSION":4.2 "cd ~/code/work/cspire/launchdeck/launchdeck_portal_api" "C-m"
# tmux send-keys -t "$SESSION":4.2 "devspace purge" C-m
tmux send-keys -t "$SESSION":4.2 "devspace run-pipeline debug -p smesser-dev -n smesser-dev" C-m
tmux select-pane -t "$SESSION":4.2
# ZOOM A PANE:
# tmux resize-pane -Z -t "$SESSION":3.2

tmux -2 select-window -t "$SESSION":2
tmux -2 select-pane -t "$SESSION":2.1

tmux setenv -t ${SESSION} 'SESSION_ICON' "${SESSION_ICON}"
tmux setenv -t ${SESSION} 'SESSION_FG' "${SESSION_FG}"
# tmux setenv -t ${SESSION} 'SESSION_BG' "${SESSION_BG}"
