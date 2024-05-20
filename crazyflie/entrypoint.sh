#!/bin/bash
set -e

# setup environment
export SHELL=/bin/bash
echo 'alias vim=nvim' >> ~/.bashrc

exec "$@"
