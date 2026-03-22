FROM nvidia/cuda:12.9.0-runtime-ubuntu24.04

ARG USER=root
ARG USER_ID=1000
ARG GROUP_ID=1001

ARG DEBIAN_FRONTEND=interactive

SHELL ["/bin/bash", "-c"]

##### Environment variables #####
ENV CUDA_HOME=/usr/local/cuda
ENV ROS_DISTRO=jazzy
ENV PIP_BREAK_SYSTEM_PACKAGES=1

##### Essential packages #####
RUN apt-get update && apt-get install -y \
    python3-pip \
    python-is-python3 \
    git \
    openssh-client \
    wget \
    vim \
    curl \
    build-essential

##### ROS2 setup #####
RUN apt-get install locales -y
RUN locale-gen en_US.UTF-8 en_US
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt install software-properties-common -y
RUN add-apt-repository universe -y

RUN apt-get update \
  && apt-get install -y ca-certificates curl

ARG ROS_APT_SOURCE_VERSION=1.1.0
RUN export CODENAME=$(. /etc/os-release && echo $VERSION_CODENAME) && \
    curl -L -s -o /tmp/ros2-apt-source.deb \
      "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${CODENAME}_all.deb" && \
    apt-get install -y /tmp/ros2-apt-source.deb && \
    rm -f /tmp/ros2-apt-source.deb

RUN apt upgrade -y
RUN apt update && apt install ros-dev-tools ros-$ROS_DISTRO-desktop -y
RUN rosdep init
RUN rosdep update

##### SSH setup #####
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

##### g2o from source #####
WORKDIR /root/deps
RUN --mount=type=ssh git clone git@github.com:RainerKuemmerle/g2o.git
WORKDIR /root/deps/g2o/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DG2O_USE_OPENGL=OFF -DG2O_USE_CSPARSE=ON -DG2O_USE_CHOLMOD=ON -DG2O_USE_CUDA=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
RUN make -j$(nproc)
RUN make install

##### Deps workspace (message packages + registration libs) #####
WORKDIR /opt/deps_ws/
COPY ./complementary_deps.repos ./complementary_deps.repos
RUN --mount=type=ssh vcs import < complementary_deps.repos

RUN source /opt/ros/$ROS_DISTRO/setup.bash && rosdep install -y --from-paths ./src --ignore-src
RUN source /opt/ros/$ROS_DISTRO/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

RUN chmod -R a+rX /opt/deps_ws
RUN echo "source /opt/deps_ws/install/setup.bash" >> ~/.bashrc

##### Install s-graphs system dependencies #####
WORKDIR /tmp/sgraphs_deps/src
RUN --mount=type=ssh git clone git@github.com:snt-arg/situational_graphs.git
WORKDIR /tmp/sgraphs_deps/
RUN source /opt/deps_ws/install/setup.bash && rosdep install -y --from-paths ./src --ignore-src --skip-keys "situational_graphs_reasoning"
RUN rm -rf /tmp/sgraphs_deps

##### Python deps for geometric room detection #####
COPY ./requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

##### Entrypoint #####
WORKDIR /root
RUN echo "source /root/.complementary_bashrc" >> ~/.bashrc
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
