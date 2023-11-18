FROM ubuntu:22.04

RUN rm -rf /var/lib/apt/lists/*
RUN apt -y update
RUN apt -y upgrade
RUN apt -y install locales git wget curl gnupg2 lsb-release python3-pip vim python3-argcomplete

# setup locale
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# setup timezone
RUN sh -c 'ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime'
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y install tzdata

# install ros2 humble desktop and build tools
WORKDIR "/root"
RUN apt -y install software-properties-common
RUN add-apt-repository universe
RUN apt update

ADD https://raw.githubusercontent.com/ros/rosdistro/master/ros.key /tmp/ros.asc
RUN apt-key add /tmp/ros.asc
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
RUN apt -y update && apt -y upgrade
RUN apt -y install ros-humble-ros-base
RUN apt -y install build-essential cmake python3-colcon-common-extensions python3-rosdep python3-setuptools python3-vcstool libbullet-dev libpython3-dev

# install Fast-RTPS dependencies
RUN apt -y --no-install-recommends install libasio-dev libtinyxml2-dev
# install Cyclone DDS dependencies
RUN apt -y --no-install-recommends install libcunit1-dev

# setup ros2 workspace

WORKDIR /root
RUN rosdep init
RUN rosdep update

COPY . /root

# downgrade setuptools to supress warning
RUN pip3 install -U pip
RUN pip3 install setuptools==58.2.0

# container bash setup for ros2 workspace
RUN sh -c 'echo "export LANG=en_US.UTF-8" >> /root/.bashrc'
RUN sh -c 'echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc'
RUN sh -c 'echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc'

ENV PYTHONPATH=$PYTHONPATH:/root
