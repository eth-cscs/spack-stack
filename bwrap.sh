#!/bin/sh

# Put spack in the path
export PATH="/dev/shm/spack/bin:$PATH"

# Map /dev/shm/apps to /apps
bwrap \
    --dev-bind / / \
    --tmpfs /tmp --bind "/dev/shm/apps" "/apps" \
    --bind "$PWD" "$PWD" \
    "$@"