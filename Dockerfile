# pull docker image from docker hub
FROM crops/poky

# change user to root
USER root
RUN echo "I am $(whoami)"

# install tools
RUN apt-get update
RUN apt-get install tree -y
RUN apt-get install vim -y
