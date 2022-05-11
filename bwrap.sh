#!/bin/sh

# Simple wrapper around bwrap that:
# 1. binds `/dev/shm/apps` to `/apps` for faster builds
# 2. always uses a fresh /tmp dir (to allow concurrent cuda/mkl installs)

mkdir -p /dev/shm/apps

# Map /dev/shm/apps to /apps
bwrap \
    --dev-bind / / \
    --tmpfs /tmp \
    --bind "/dev/shm/apps" "/apps" \
    --bind "/apps/manali/UES/hstoppel" "/apps/manali/UES/hstoppel" \
    "$@"
