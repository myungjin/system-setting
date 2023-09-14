#!/usr/bin/env bash

# run tmux before executing this script

n_copies=1

while getopts 'n:h' opt; do
    case "$opt" in
        n) n_copies=$(($OPTARG))
           ;;
   
        ?|h)
            echo "Usage: $(basename $0) [-n <num>] <a list of hosts>"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND -1))"

starttmux() {
    if [ -z "$HOSTS" ]; then
       echo -n "Please provide of list of hosts separated by spaces [ENTER]: "
       read HOSTS
    fi

    local hosts=( $HOSTS )

    tmux new-window "ssh ${hosts[0]}"
    unset hosts[0]
    for host in "${hosts[@]}"; do
        for i in $(seq 1 $n_copies); do
            tmux split-window -h "ssh $host"
            tmux select-layout tiled > /dev/null
        done
    done
    tmux select-pane -t 0
    tmux set-window-option synchronize-panes on > /dev/null

}

HOSTS=${HOSTS:=$*}

starttmux
