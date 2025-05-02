FROM  continuumio/miniconda3

WORKDIR /root/

# RUN apt-get update
# RUN apt-get install apt-utils sudo software-properties-common ca-certificates curl gnupg -y
# RUN add-apt-repository ppa:neovim-ppa/unstable && apt update 

# # NODE JS and PYNVIM for use nvim
# ARG NODE_MAJOR=20
# RUN mkdir -p /etc/apt/keyrings
# RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
# RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# RUN apt-get update 
# RUN apt-get install neovim nodejs python3-pip -y
# RUN pip3 install pynvim 

# this folders are for nvim
# RUN mkdir .config
# RUN mkdir .local/share -p

# install opendjk-11
RUN apt-get update
RUN apt-get install openjdk-11-jdk -y
# Install Jupyter
WORKDIR /root/
RUN apt-get install wget -y
RUN wget https://raw.githubusercontent.com/Systems-Modeling/SysML-v2-Release/master/install/jupyter/install.sh
RUN wget https://raw.githubusercontent.com/Systems-Modeling/SysML-v2-Release/master/install/jupyter/install.py
RUN chmod +x install.sh
RUN cat ./install.sh
RUN ./install.sh


COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
