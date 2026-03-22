#!/bin/bash
set -e

# setup ros2 environment

cp ~/.gitconfig_local ~/.gitconfig 2>/dev/null || true
git config --global --add safe.directory '*'

exec "$@"
