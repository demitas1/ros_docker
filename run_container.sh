#!/bin/bash

container_name="ros2_humble"
network_name="ros2_network"
ros_domain_id=21
shm_size="2gb"
shm_volume="/dev/shm:/dev/shm"
option=""

docker network create "${network_name}"

docker run --net="${network_name}" -d --rm -it --name "${container_name}" -e TZ=Asia/Tokyo -e ROS_DOMAIN_ID="${ros_domain_id}" ${option} --mount type=bind,source="$(pwd)/work/src",target=/root/work/src ros2_humble_img

