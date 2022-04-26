#!/bin/sh

# Put spack in the path
export PATH="/dev/shm/spack/bin:$PATH"

mkdir -p /dev/shm/apps

# Map /dev/shm/apps to /apps
bwrap \
    --dev-bind / / \
    --tmpfs /tmp \
    --bind "/dev/shm/apps" "/apps" \
    --bind "/apps/manali/UES/hstoppel" "/apps/manali/UES/hstoppel" \
    "$@"
