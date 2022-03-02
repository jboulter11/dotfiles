#!/bin/sh

user_ack () {
    echo "Proceed? (y/n)"
    read resp
    [[ "$resp" =~ y|Y ]] && return 0
    return 1
}
