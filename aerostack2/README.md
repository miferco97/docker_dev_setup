# Aerostack2 container

This container considers that you have the source files in ~/aerostack2_ws/

## Useful commands

For building the image

```
$ docker build . -t aerostack2 
```

For deploying the container
```
$ docker compose up -d 
# if this fail try 
$ docker-compose up -d 
```

For accessing the container (this can be used wherever not necesarily from this folder)

```
$docker exec -it aerostack2 /bin/bash
```

For stopping the container
```
docker compose down
# if this fail try 
docker-compose down
```

