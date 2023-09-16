FROM ubuntu:22.04

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
RUN pip3 install pynvim

## create an user
RUN useradd --create-home --shell /bin/bash $USERNAME && echo "$USERNAME:$PASSWD" | chpasswd && adduser $USERNAME sudo
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $USERNAME
WORKDIR /home/$USERNAME
# this folders are for nvim
RUN mkdir .config
RUN mkdir .local/share -p
