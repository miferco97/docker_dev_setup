#!/bin/bash
set -e

sed -i "s/QColor(float(r), float(g), float(b))/QColor.fromRgbF(float(r), float(g), float(b))/" \
  /opt/ros/humble/local/lib/python3.10/dist-packages/qt_dotgraph/dot_to_qt.py

# setup safe
# cp /root/.gitconfig_local /root/.gitconfig
# git config --global --add safe.directory '*'

# setup ros2 environment
export SHELL=/bin/bash
echo 'alias vim=nvim' >> ~/.bashrc
echo 'alias colcon-lcov=" rm -rf lcov ; colcon build --symlink-install --mixin coverage-gcc && colcon test && colcon lcov-result"' >> ~/.bashrc
cp /root/.gitconfig_local /root/.gitconfig
git config --global --add safe.directory /root/aerostack2_ws/src/aerostack2


exec "$@"
