ARG BASE_IMAGE=nvidia/cuda:12.9.0-runtime-ubuntu24.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_DISTRO=jazzy
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]

# --- Locale and base packages ---
RUN apt-get update && apt-get install -y \
    locales \
    software-properties-common \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg2 \
    lsb-release \
    build-essential \
    cmake \
    python3-pip \
    python-is-python3 \
    openssh-client \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# --- ROS 2 Jazzy ---
RUN add-apt-repository universe -y
RUN ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') && \
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" && \
    apt-get install -y /tmp/ros2-apt-source.deb && \
    rm -f /tmp/ros2-apt-source.deb

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    ros-${ROS_DISTRO}-desktop \
    ros-dev-tools \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-colcon-mixin

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /etc/bash.bashrc

# --- Initialize rosdep ---
RUN rosdep init && rosdep update

# --- SSH setup ---
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /root/

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
