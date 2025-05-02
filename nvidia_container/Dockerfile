# Copyright (c) 2021-2024, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.
#
# Docker file to build on x86_64
# https://docs.nvidia.com/deeplearning/frameworks/user-guide/index.html
# https://docs.nvidia.com/deeplearning/frameworks/support-matrix/index.html
ARG BASE_IMAGE=nvcr.io/nvidia/tritonserver:23.10-py3
FROM ${BASE_IMAGE}
 
USER root

# Store list of packages (must be first)
RUN mkdir -p /opt/nvidia/isaac_ros_dev_base && dpkg-query -W | sort > /opt/nvidia/isaac_ros_dev_base/x86_64-start-packages.csv

# disable terminal interaction for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL /bin/bash
SHELL ["/bin/bash", "-c"]

# Ensure we have universe
RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y \
        software-properties-common \
&& add-apt-repository universe \
&& apt-get update

# Add Isaac apt repository
RUN --mount=type=cache,target=/var/cache/apt \
    wget -qO - https://isaac.download.nvidia.com/isaac-ros/repos.key | apt-key add - && \
    grep -qxF "deb https://isaac.download.nvidia.com/isaac-ros/release-3 $(lsb_release -cs) release-3.0" /etc/apt/sources.list || \
    echo "deb https://isaac.download.nvidia.com/isaac-ros/release-3 $(lsb_release -cs) release-3.0" | tee -a /etc/apt/sources.list \
    && apt-get update

# Fundamentals
RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y \
        apt-transport-https \
        bash-completion \
        build-essential \
        ca-certificates \
        clang-format \
        cmake \
        curl \
        git \
        git-lfs \
        gnupg2 \
        iputils-ping \
        locales \
        lsb-release \
        rsync \
        software-properties-common \
        wget \
        vim \
        unzip \
        mlocate \
	libgoogle-glog-dev

# Python basics
RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y \
        python3-pip \
        python3-pybind11 \
        python3-pytest \
        python3-pytest-repeat \
        python3-pytest-rerunfailures \
        python3-pytest-cov

# Set Python3 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Core dev libraries
RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y \
        ffmpeg \
        libasio-dev \
        libbullet-dev \
        libtinyxml2-dev \
        libcunit1-dev \
        libmnl0 \
        libmnl-dev \
        libv4l-dev \
        libyaml-cpp-dev \
        libopencv-dev \
        libpython3.10 \
        libx264-dev \
        kmod \
        patchelf \
        python3-opencv \
        nlohmann-json3-dev

# Python3 (PIP)
RUN python3 -m pip install -U \
        argcomplete \
        autopep8 \
        flake8==4.0.1 \
        flake8-blind-except \
        flake8-builtins \
        flake8-class-newline \
        flake8-comprehensions \
        flake8-deprecated \
        flake8-docstrings \
        flake8-import-order \
        flake8-quotes \
        gpustat==0.6.0 \
        onnx \
        pydocstyle \
        scikit-learn \
        ninja \
        networkx \
        "numpy>=1.24.4,<2" \
        numpy-quaternion \
        pyyaml \
        "setuptools_scm>=6.2" \
        trimesh \
        "yourdfpy>=0.0.53" \
        "warp-lang>=0.9.0" \
        "scipy>=1.7.0" \
        tqdm \
        importlib_resources

# Install nvv4l2 for GXF Multimedia h264 codec
RUN --mount=type=cache,target=/var/cache/apt \
apt-get update && apt-get install -y \
        nvv4l2 \
&& ln -s /usr/lib/x86_64-linux-gnu/libnvcuvid.so.1 /usr/lib/x86_64-linux-gnu/libnvcuvid.so \
&& ln -s /usr/lib/x86_64-linux-gnu/libnvidia-encode.so.1 /usr/lib/x86_64-linux-gnu/libnvidia-encode.so

# Install VPI packages
ARG HAS_GPU="true"
RUN --mount=type=cache,target=/var/cache/apt \
    if [ "$HAS_GPU" = "true" ]; then \
	set -e ; \
        apt-key adv --fetch-key https://repo.download.nvidia.com/jetson/jetson-ota-public.asc ; \
        add-apt-repository "deb http://repo.download.nvidia.com/jetson/x86_64/$(lsb_release -cs) r36.3 main" ; \
        apt-get update ; \
        apt-get install libnvvpi3 vpi3-dev ; \
    fi

# Pytorch
RUN python3 -m pip install -U --extra-index-url https://download.pytorch.org/whl/cu121 \
        torch \
        torchvision \
        torchaudio

# Install Tao converter
RUN mkdir -p /opt/nvidia/tao && cd /opt/nvidia/tao && \
    wget --content-disposition 'https://api.ngc.nvidia.com/v2/resources/org/nvidia/team/tao/tao-converter/v5.1.0_8.6.3.1_x86/files?redirect=true&path=tao-converter' -O tao-converter && \
    chmod 755 tao-converter

ENV PATH="${PATH}:/opt/nvidia/tao"
ENV TRT_LIB_PATH="/usr/lib/x86_64-linux-gnu"
ENV TRT_INC_PATH="/usr/include/x86_64-linux-gnu"

# Update environment
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/tritonserver/lib"

# Install CV-CUDA
RUN --mount=type=cache,target=/var/cache/apt \
    cd /tmp && \
    wget https://github.com/CVCUDA/CV-CUDA/releases/download/v0.5.0-beta/nvcv-lib-0.5.0_beta-cuda12-x86_64-linux.deb && \
    dpkg -i nvcv-lib-0.5.0_beta-cuda12-x86_64-linux.deb && \
    wget https://github.com/CVCUDA/CV-CUDA/releases/download/v0.5.0-beta/nvcv-dev-0.5.0_beta-cuda12-x86_64-linux.deb && \
    dpkg -i nvcv-dev-0.5.0_beta-cuda12-x86_64-linux.deb

# Store list of packages (must be last)
RUN mkdir -p /opt/nvidia/isaac_ros_dev_base && dpkg-query -W | sort > /opt/nvidia/isaac_ros_dev_base/x86_64-end-packages.csv

## FROM HERE IS THE SAME AS THE ORIGINAL DOCKERFILE start


RUN apt update && apt install locales -y
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN apt install software-properties-common -y
RUN add-apt-repository universe -y

RUN apt update && apt install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt update
# sudo apt upgrade -y
RUN apt install ros-humble-desktop  ros-dev-tools -y

# AS2 


RUN apt-get install python3-rosdep  \
                python3-pip     \
                python3-colcon-common-extensions \
                python3-colcon-mixin \
                ros-dev-tools -y

RUN apt-get install python3-flake8 \
                python3-flake8-builtins  \
                python3-flake8-comprehensions \
                python3-flake8-docstrings \
                python3-flake8-import-order \
                python3-flake8-quotes -y

RUN pip3 install pylint
RUN pip3 install flake8==4.0.1
RUN pip3 install pycodestyle==2.8
RUN pip3 install cmakelint cpplint

RUN apt-get install cppcheck lcov -y

# RUN colcon mixin update default
RUN rm -rf log # remove log folder

RUN pip3 install colcon-lcov-result cpplint cmakelint
RUN pip3 install PySimpleGUI-4-foss

RUN mkdir -p /root/aerostack2_ws/src/
WORKDIR /root/aerostack2_ws/src/
RUN git clone https://github.com/aerostack2/aerostack2.git -b main

WORKDIR /root/aerostack2_ws
RUN rosdep init
RUN rosdep update
RUN rosdep fix-permissions
ENV ROS_DISTRO=humble
RUN . /opt/ros/$ROS_DISTRO/setup.sh && rosdep install --from-paths src --ignore-src -r -y

# RUN . /opt/ros/$ROS_DISTRO/setup.sh && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc
RUN echo 'export AEROSTACK2_PATH=/root/aerostack2_ws/src/aerostack2' >> ~/.bashrc
RUN echo 'source $AEROSTACK2_PATH/as2_cli/setup_env.bash' >> ~/.bashrc


# LAST STEPS
WORKDIR /root/

RUN add-apt-repository ppa:neovim-ppa/unstable && apt update 
RUN apt-get install apt-utils software-properties-common ca-certificates curl gnupg -y

# NODE JS and PYNVIM for use nvim
ARG NODE_MAJOR=20
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update 
RUN apt-get install neovim nodejs python3-pip -y
RUN pip3 install pynvim 

# this folders are for nvim
RUN mkdir .config
RUN mkdir .local/share -p

RUN apt-get install tmux tmuxinator -y

RUN apt-get install cpplint cppcheck -y
RUN pip install cmakelint -U

# Gazebo Fortress clean uninstall
RUN apt remove ignition* -y
RUN apt autoremove -y

# Install Gazebo Harmonic
RUN apt-get install lsb-release wget gnupg && apt-get update
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt-get update && apt-get install -y -q gz-harmonic

# Install ros-gazebo dependencies
RUN apt update && apt install ros-humble-ros-gzharmonic -y


# Install dependencies
RUN python3 -m pip install -U numpy==1.26
RUN python3 -m pip install -U lightning
RUN python3 -m pip install -U scikit-image
RUN python3 -m pip install -U rosbags
RUN python3 -m pip install -U rosbags-image
RUN python3 -m pip install -U tensorboard
RUN python3 -m pip install -U labelbox
RUN python3 -m pip install -U natsort


RUN apt remove ros-humble-librealsense2 -y
RUN git clone https://github.com/IntelRealSense/librealsense.git -b v2.50.0 && cd librealsense && mkdir build && cd build && cmake .. -DFORCE_RSUSB_BACKEND=1 && make -j12 && sudo make install
RUN mkdir -p /etc/udev/rules.d
RUN cp ~/librealsense/config/99-realsense-libusb.rules /etc/udev/rules.d/99-realsense-libusb.rules

RUN apt install ros-humble-plotjuggler-ros ripgrep xclip ros-humble-rqt-tf-tree -y

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]





