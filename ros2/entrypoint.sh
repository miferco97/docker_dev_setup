#!/bin/bash
set -e

sed -i "s/QColor(float(r), float(g), float(b))/QColor.fromRgbF(float(r), float(g), float(b))/" \
  /opt/ros/humble/local/lib/python3.10/dist-packages/qt_dotgraph/dot_to_qt.py

# setup safe
cp /root/.gitconfig_local /root/.gitconfig
git config --global --add safe.directory '*'
# setup ros2 environment
echo 'source "/opt/ros/$ROS_DISTRO/setup.bash"' >> ~/.bashrc
echo 'export AEROSTACK2_PATH=/root/aerostack2_ws/src/aerostack2/' >> ~/.bashrc
echo 'source $AEROSTACK2_PATH/as2_cli/setup_env.bash' >> ~/.bashrc 
echo 'source ~/knowledge_graphs_ws/install/setup.bash' >> ~/.bashrc
echo 'alias colcon-lcov=" rm -rf lcov ; colcon build --symlink-install --mixin coverage-gcc && colcon test && colcon lcov-result"' >> ~/.bashrc

exec "$@"
