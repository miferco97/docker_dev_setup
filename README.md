# Docker dev setup

Some examples of different docker configurations for using while developing different applications
The idea is to handle all the specific configurations of each project inside different containers while keeping the source files inside the main machine (to ease developing and to have persisintence in files).

As this containers are ment for developing and not for deploying there are several things that should be taken into consideration:
 - Containers share the host network and the DISPLAY: This is done for ease the use of Graphical Aplications inside the container.
 - Neovim and tmux config are imported from the host machine: a lot of volumes are created related with this and some dependencies inside the Dockerfiles.
 - SSH keys can be forwarded by uncommenting .ssh folder line in docker-compose.yml

