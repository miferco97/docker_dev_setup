#!/bin/bash
set -e

# setup environment
export SHELL=/bin/bash
echo 'alias vim=nvim' >> ~/.bashrc
echo 'alias run-jupyter="jupyter-lab --no-browser --allow-root --notebook-dir=/root/workspace"' >> ~/.bashrc

exec "$@"
