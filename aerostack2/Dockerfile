FROM aerostack2/nightly-humble

RUN apt-get install ros-humble-mavros ros-humble-mavros-extras -y
WORKDIR /tmp/
RUN wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh 
RUN chmod +x install_geographiclib_datasets.sh
RUN ./install_geographiclib_datasets.sh

WORKDIR /root/
# Setup Cyclone and Zenoh

RUN echo "deb [trusted=yes] https://download.eclipse.org/zenoh/debian-repo/ /" | sudo tee -a /etc/apt/sources.list > /dev/null
RUN apt update && apt install ros-humble-rmw-cyclonedds-cpp zenoh-bridge-ros2dds -y


COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
