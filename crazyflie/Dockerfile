FROM aerostack2/nightly-humble:latest

WORKDIR /root/

RUN apt-get update
RUN apt-get install apt-utils sudo software-properties-common ca-certificates curl gnupg -y
RUN add-apt-repository ppa:neovim-ppa/unstable && apt update 

# NODE JS and PYNVIM for use nvim
ARG NODE_MAJOR=20
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update 
RUN apt-get install neovim nodejs python3-pip -y
RUN pip3 install pynvim 

# this folders are for nvim
RUN mkdir .config
RUN mkdir .local/share -p

RUN apt-get install tmux tmuxinator -y

RUN apt-get install git python3-pip libxcb-xinerama0 libxcb-cursor0 -y
# RUN apt-get install libusb-1.0-0-dev libudev-dev ffmpeg libsm6 libxext6  -y
RUN pip3 install --upgrade pip
RUN pip3 install cfclient
RUN apt install udev usbutils -y


# RUN groupadd plugdev
RUN usermod -aG plugdev root

COPY ./rules/99-bitcraze.rules /etc/udev/rules.d/99-bitcraze.rules

# FIRMWARE UTILS

RUN apt-get install make gcc-arm-none-eabi build-essential libncurses5-dev -y
# RUN git clone --recursive https://github.com/bitcraze/crazyflie-firmware.git
# RUN git clone https://github.com/bitcraze/aideck-gap8-examples


COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
