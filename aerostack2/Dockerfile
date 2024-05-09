FROM aerostack2-nightly-humble

WORKDIR /root/

RUN add-apt-repository ppa:neovim-ppa/unstable && apt update 
RUN apt-get install apt-utils sudo software-properties-common ca-certificates curl gnupg -y

# NODE JS and PYNVIM for use nvim
ARG NODE_MAJOR=20
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update 
RUN apt-get install neovim nodejs python3-pip cppcheck -y
RUN pip3 install pynvim cpplint 

# this folders are for nvim
RUN mkdir .config
RUN mkdir .local/share -p

RUN apt-get install tmux tmuxinator -y
RUN pip3 install cmakelint

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
