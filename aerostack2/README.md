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
$ docker compose down
# if this fail try 
$ docker-compose down
```


## HOW TO GENERATE AS2 DEPENDENCIES

We will use the following command to dump the dependencies of the Aerostack2 project into a file called as2_install_dependencies.bash

```
rosdep install --from-paths src --ignore-src --reinstall -s > as2_install_dependencies.bash
# if we want to remove the sudo -H from the script we can use the following command
sed -i "s/sudo -H //g" as2_install_dependencies.bash 
sed -i "s/$/ -y \&\& \\\ /" as2_install_dependencies.bash && echo 'echo "dependecies installed correctly"' >> as2_install_dependencies.bash 
```

