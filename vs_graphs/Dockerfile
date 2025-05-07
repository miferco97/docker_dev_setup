FROM amd64/ros:noetic-perception-focal
 
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common git \
        build-essential cmake libeigen3-dev \
        python3-catkin-tools libopencv-dev \
        libssl-dev \
        libudev-dev \
        libusb-1.0-0-dev \
        libepoxy-dev \
        gcc 

RUN apt-get update && \
    apt-get install -y \
        ros-${ROS_DISTRO}-realsense2-camera  \
        ros-${ROS_DISTRO}-hector-trajectory-server

WORKDIR /deps

RUN git clone https://github.com/stevenlovegrove/Pangolin && \
    cd Pangolin && git checkout v0.6 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++11 .. && \
    make -j$nproc && make install

WORKDIR /ws/src

RUN git clone  https://github.com/snt-arg/visual_sgraphs.git
RUN git clone -b noetic-devel https://github.com/pal-robotics/aruco_ros.git 
RUN git clone https://github.com/snt-arg/scene_segment_ros.git

WORKDIR /ws/
RUN rosdep update && \
    rosdep install --from-paths . --ignore-src --rosdistro ${ROS_DISTRO} -y && \
    catkin config --extend /opt/ros/noetic

RUN catkin build

RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /ws/devel/setup.bash" >> ~/.bashrc


# Build Entrypoint
RUN echo "#!/bin/bash" >> /entrypoint.sh \
    && echo "source /opt/ros/noetic/setup.bash" >> /entrypoint.sh \
    && echo "source /ws/devel/setup.bash" >> /entrypoint.sh \
    && echo 'exec "$@"' >> /entrypoint.sh \
    && chmod a+x /entrypoint.sh

WORKDIR /ws

# # LAST STEPS
# workdir /root/

# run add-apt-repository ppa:neovim-ppa/unstable && apt update 
# run apt-get install apt-utils software-properties-common ca-certificates curl gnupg -y

# # node js and pynvim for use nvim
# arg node_major=20
# run mkdir -p /etc/apt/keyrings
# run curl -fssl https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
# run echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$node_major.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# run apt-get update 
# run apt-get install neovim nodejs python3-pip -y
# run pip3 install pynvim 

# # this folders are for nvim
# run mkdir .config
# run mkdir .local/share -p

# run apt-get install tmux tmuxinator -y

# run apt-get install cpplint cppcheck -y
# run pip install cmakelint -u

# # Gazebo Fortress clean uninstall
# RUN apt remove ignition* -y
# RUN apt autoremove -y

# # Install Gazebo Harmonic
# RUN apt-get install lsb-release wget gnupg && apt-get update
# RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
# RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
# RUN apt-get update && apt-get install -y -q gz-harmonic

# # Install ros-gazebo dependencies
# RUN apt update && apt install ros-humble-ros-gzharmonic -y

# # Install dependencies
# RUN python3 -m pip install -U numpy==1.26
# RUN python3 -m pip install -U lightning
# RUN python3 -m pip install -U scikit-image
# RUN python3 -m pip install -U rosbags
# RUN python3 -m pip install -U rosbags-image
# RUN python3 -m pip install -U tensorboard
# RUN python3 -m pip install -U labelbox
# RUN python3 -m pip install -U natsort


# RUN apt update && apt install ros-humble-rmw-cyclonedds-cpp -y
# RUN apt install ros-humble-plotjuggler-ros ripgrep xclip ros-humble-rqt-tf-tree -y

# # OPEN VINS DEPENDENCIES
# RUN apt-get install libeigen3-dev libboost-all-dev libceres-dev -y

# RUN python3 -m pip install opencv-python
# RUN python3 -m pip uninstall opencv-python-headless -y
# RUN python3 -m pip install transforms3d

# # G2O DEPENDENCIES
# RUN apt-get update
# RUN apt-get install libspdlog-dev -y
# RUN apt-get install libsuitesparse-dev -y
# RUN apt-get install qtdeclarative5-dev -y
# RUN apt-get install qt5-qmake -y
# RUN apt-get install libqglviewer-dev-qt5 -y
# RUN apt-get install ros-humble-backward-ros -y

# COPY ./entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["bash", "/entrypoint.sh"]

