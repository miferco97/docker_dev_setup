FROM nvcr.io/nvidia/cuda-dl-base:25.04-cuda12.9-runtime-ubuntu24.04

### FIX MPI ISSUE ###
RUN mkdir -p /opt/hpcx/ompi/lib/x86_64-linux-gnu
RUN ln -s /opt/hpcx/ompi /opt/hpcx/ompi/lib/x86_64-linux-gnu/openmpi
RUN dpkg-reconfigure libc-bin

ARG USER=root
ARG USER_ID=1000
ARG GROUP_ID=1001

ARG DEBIAN_FRONTEND=interactive
 
##### Environment variables #####
ENV CUDA_HOME=/usr/local/cuda
ENV ROS_DISTRO=jazzy
 
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

RUN export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') ;\
    curl -L -s -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" \
    && apt-get update \
    && apt-get install /tmp/ros2-apt-source.deb \
    && rm -f /tmp/ros2-apt-source.deb

RUN apt upgrade -y
RUN apt update && apt install ros-dev-tools ros-$ROS_DISTRO-desktop -y
RUN rosdep init
RUN rosdep update 

##### SSH setup #####
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

##### NVIM setup #####
 
COPY ./setup_nvim_for_docker.bash /.setup_nvim_for_docker.bash
RUN chmod +x /.setup_nvim_for_docker.bash
RUN /.setup_nvim_for_docker.bash
RUN rm /.setup_nvim_for_docker.bash
RUN apt-get install tmux tmuxinator -y

# GTSAM deps

RUN apt-get install libboost-all-dev -y
RUN apt-get install libtbb-dev -y

WORKDIR /root/deps

RUN --mount=type=ssh git clone git@github.com:borglab/gtsam.git -b 4.2
RUN cd gtsam && git submodule update --init --recursive
WORKDIR /root/deps/gtsam/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_EXAMPLES=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DGTSAM_USE_SYSTEM_EIGEN=ON
RUN make -j$(nproc)
RUN make install


WORKDIR /root/deps_ws/
COPY ./complementary_deps.repos ./complementary_deps.repos
RUN --mount=type=ssh vcs import < complementary_deps.repos

ENV PIP_BREAK_SYSTEM_PACKAGES=1
RUN rosdep install -y --from-paths ./src --ignore-src 
RUN source /opt/ros/$ROS_DISTRO/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

RUN echo "source /root/deps_ws/install/setup.bash" >> ~/.bashrc

WORKDIR /root/workspace/src
RUN --mount=type=ssh git clone git@github.com:snt-arg/situational_graphs.git
WORKDIR /root/workspace/
RUN source /root/deps_ws/install/setup.bash && rosdep install -y --from-paths ./src --ignore-src 
# RUN source /root/deps_ws/install/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

#install g2o

WORKDIR /root/deps
RUN --mount=type=ssh git clone git@github.com:RainerKuemmerle/g2o.git
WORKDIR /root/deps/g2o/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DG2O_USE_OPENGL=OFF -DG2O_USE_CSPARSE=ON -DG2O_USE_CHOLMOD=ON -DG2O_USE_CUDA=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 
RUN make -j$(nproc)
RUN make install


#export ros variables in bashrc
WORKDIR /root

RUN echo "source /root/.complementary_bashrc" >> ~/.bashrc
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]


