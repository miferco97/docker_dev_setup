FROM osrf/ros:humble-desktop

#create an user with a /home/user directory
ARG USERNAME=user
ARG PASSWD=test
RUN apt update
RUN apt-get install apt-utils sudo software-properties-common -y

# NODE JS and PYNVIM for use nvim
RUN add-apt-repository ppa:neovim-ppa/unstable && apt update
RUN apt-get install neovim -y
ARG NODE_MAJOR=20
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update
RUN apt-get install nodejs -y
RUN apt-get install python3-pip -y


## ROS2 utils

RUN apt install git python3-rosdep python3-pip python3-colcon-common-extensions -y
RUN apt install ros-dev-tools git -y

## create an user
RUN useradd --create-home --shell /bin/bash $USERNAME && echo "$USERNAME:$PASSWD" | chpasswd && adduser $USERNAME sudo
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME
# this folders are for nvim

RUN pip3 install pynvim
RUN mkdir .config
RUN mkdir .local/share -p

RUN mkdir -p ~/aerostack2_ws/src/ && cd ~/aerostack2_ws/src/ && git clone https://github.com/aerostack2/aerostack2.git
RUN rosdep update

RUN cd ~/aerostack2_ws && rosdep install -y -r -q --from-paths src --ignore-src

RUN sudo apt install ros-$ROS_DISTRO-ros-gz* -y
RUN sudo apt upgrade -y
RUN sudo apt install tmux tmuxinator -y

RUN echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc
RUN echo 'export AEROSTACK2_PATH=/home/user/aerostack2_ws/src/aerostack2/' >> ~/.bashrc
RUN echo 'source $AEROSTACK2_PATH/as2_cli/setup_env.bash' >> ~/.bashrc 
