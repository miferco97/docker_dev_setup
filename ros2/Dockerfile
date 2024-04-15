FROM osrf/ros:humble-desktop

WORKDIR /root/

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
RUN pip3 install pynvim
RUN apt-get install ripgrep -y

# this folders are for nvim
RUN mkdir .config
RUN mkdir .local/share -p
RUN echo 'alias vim=nvim' >> ~/.bashrc

RUN sudo apt install tmux tmuxinator -y
## ROS2 utils

RUN apt install git python3-rosdep python3-pip python3-colcon-common-extensions -y
RUN apt install ros-dev-tools git -y

RUN rosdep update
COPY ./dependency_files/ /root/dependency_files/


RUN apt install cppcheck -y
RUN pip3 install cpplint

RUN for file in /root/dependency_files/*; do chmod +x $file; bash $file; done
RUN rm -rf /root/dependency_files


RUN apt install python3-colcon-mixin
RUN colcon mixin update default
RUN rm -rf log # remove log folder
RUN pip3 install colcon-lcov-result
RUN apt install lcov -y

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
