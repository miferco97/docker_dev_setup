# Ubuntu 22.04 container

This container have just the minimal configuration for sharing Nvim and Tmux configs with the host machine

## Useful commands

For building the image

```
$ docker build . -t ubuntu_basic 
```

For deploying the container
```
$ docker compose up -d 
# if this fail try 
$ docker-compose up -d 
```

For accessing the container (this can be used wherever not necesarily from this folder)

```
$docker exec -it ubuntu_basic /bin/bash
```

For stopping the container
```
$ docker compose down
# if this fail try 
$ docker-compose down
```

