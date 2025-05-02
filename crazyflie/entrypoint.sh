#!/bin/bash
set -e

# setup environment
export SHELL=/bin/bash
echo 'alias vim=nvim' >> ~/.bashrc
# echo 'source ~/platforms_ws/install/setup.bash' >> ~/.bashrc
echo 'export ROS_LOCALHOST_ONLY=0' >> ~/.bashrc
echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> ~/.bashrc

cp /root/.gitconfig_local /root/.gitconfig
git config --global --add safe.directory /root/aerostack2_ws/src/aerostack2

exec "$@"
