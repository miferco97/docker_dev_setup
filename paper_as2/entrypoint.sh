#!/bin/bash
set -e

sed -i "s/QColor(float(r), float(g), float(b))/QColor.fromRgbF(float(r), float(g), float(b))/" \
  /opt/ros/humble/local/lib/python3.10/dist-packages/qt_dotgraph/dot_to_qt.py

# setup ros2 environment

echo 'alias vim=nvim' >> ~/.bashrc
echo 'alias colcon-lcov=" rm -rf lcov ; colcon build --symlink-install --mixin coverage-gcc && colcon test && colcon lcov-result"' >> ~/.bashrc
echo "alias run_zenoh='echo \"zenoh-bridge-ros2dds -e tcp/<robot_ip>:7447\"'" >> ~/.bashrc

cp /root/.gitconfig_local /root/.gitconfig
git config --global --add safe.directory /root/aerostack2_ws/src/aerostack2

exec "$@"
