FROM nvcr.io/nvidia/cuda-dl-base:25.04-cuda12.9-devel-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV CUDA_HOME=/usr/local/cuda \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ROS_DISTRO=jazzy \
    PIP_BREAK_SYSTEM_PACKAGES=1

# --- Fix MPI issue ---
RUN mkdir -p /opt/hpcx/ompi/lib/x86_64-linux-gnu \
 && ln -s /opt/hpcx/ompi /opt/hpcx/ompi/lib/x86_64-linux-gnu/openmpi \
 && dpkg-reconfigure libc-bin

# --- System setup ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python-is-python3 \
    git \
    openssh-client \
    wget \
    vim \
    curl \
    libeigen3-dev \
    build-essential \
    locales \
    software-properties-common \
    lsb-release \
    gnupg2 && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN add-apt-repository universe

# --- ROS 2 Jazzy APT source setup ---
RUN ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') && \
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" && \
    apt install -y /tmp/ros2-apt-source.deb

# --- Install ROS 2 Jazzy development tools ---
RUN apt update && apt upgrade -y && \
    apt install -y ros-dev-tools ros-${ROS_DISTRO}-desktop ros-${ROS_DISTRO}-rqt-tf-tree

# --- Source ROS globally ---
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /etc/bash.bashrc

RUN apt remove --purge python3-typing-extensions -y
RUN pip3 install typing-extensions==4.11.0 

# --- Initialize rosdep ---
RUN rosdep init && rosdep update

# --- Python environment setup ---
RUN pip3 install networkx==3.1
RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch \
    torchvision

# --- CLIP and Detectron2 setup ---
ARG TORCH_CUDA_ARCH_LIST="7.5;7.0+PTX"
ENV FORCE_CUDA="1"
RUN pip3 install 'git+https://github.com/facebookresearch/detectron2.git'
RUN pip3 install 'git+https://github.com/openai/CLIP.git'

# --- SSH keys ---
# Define the SSH keys as build arguments for latter mounting
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# --- Clone repositories ---
RUN apt-get update && apt-get install -y \
    libepoxy-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    libglew-dev \
    cmake \
    build-essential \
    git

# Pangolin
WORKDIR /opt/
RUN git clone --branch v0.9.1 --depth 1 https://github.com/stevenlovegrove/Pangolin.git && \
    cd Pangolin && \
    mkdir build && cd build && \
    cmake .. && \
    make -j && \
    make install

# Cmake
ARG version=3.22
ARG build=1
WORKDIR /tmp
RUN wget https://cmake.org/files/v$version/cmake-$version.$build.tar.gz

RUN tar -xzvf cmake-$version.$build.tar.gz
WORKDIR /tmp/cmake-$version.$build
RUN ./bootstrap
RUN make -j8
RUN make install

RUN mkdir -p /workspace/src
WORKDIR /workspace/src/

# Mount the SSH keys for cloning private repositories
RUN --mount=type=ssh git clone -b ros2-jazzy git@github.com:snt-arg/visual_sgraphs.git
RUN --mount=type=ssh git clone -b ros2-jazzy git@github.com:snt-arg/scene_segment_ros.git
# RUN --mount=type=ssh git clone -b humble-devel git@github.com:pal-robotics/aruco_ros.git

# Other libraries
WORKDIR /workspace/src/visual_sgraphs/docker
RUN pip3 install --break-system-packages --ignore-installed -r requirements.txt

WORKDIR /workspace/src/

# RUN --mount=type=ssh git clone git@github.com:snt-arg/mav_voxblox_planning.git
# RUN --mount=type=ssh wstool init . ./mav_voxblox_planning/install/install_ssh.rosinstall
# RUN --mount=type=ssh wstool update

# Download the yoso checkpoint
RUN wget https://github.com/hujiecpp/YOSO/releases/download/v0.1/yoso_res50_coco.pth
RUN mv yoso_res50_coco.pth /workspace/src/scene_segment_ros/include/

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y ros-jazzy-rviz-visual-tools
RUN sudo apt install ros-jazzy-pcl-ros

RUN apt-get update && \
    apt-get install -y ros-jazzy-depth-image-proc ros-jazzy-backward-ros

WORKDIR /opt/
RUN --mount=type=ssh git clone https://github.com/Rookfighter/least-squares-cpp.git
WORKDIR /opt/least-squares-cpp
RUN cmake -B out/ -S .
RUN cmake --install out/


# Build the workspace
WORKDIR /workspace/
RUN /bin/bash -c "source /opt/ros/$ROS_DISTRO/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release && rosdep update"

# COPY ./entrypoint.sh /entrypoint.sh

# RUN chmod a+x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]

