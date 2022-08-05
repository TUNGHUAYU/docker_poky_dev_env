#!/bin/bash

###
# function
###

function FUNC_check_container_existed(){
	local ret


	if [[ $# -ne 1 ]];then
		echo "FUNC_check_container_existed <container_name>"
		exit -1
	fi

	pattern=$1
	ret=$( docker container ls | awk '{print $NF}' | grep -w "${pattern}" )

	if [[ ${ret} == "${pattern}" ]]; then
		return 1
	else 
		return 0
	fi

}


function FUNC_check_image_existed(){
	local ret


	if [[ $# -ne 1 ]];then
		echo "FUNC_check_image_existed <image_name>"
		exit -1
	fi

	pattern=$1
	ret=$( docker image ls | awk '{print $1}' | grep -w "${pattern}" )

	if [[ ${ret} == "${pattern}" ]]; then
		return 1
	else 
		return 0
	fi

}

function USAGE(){
	echo "usage $(basename $0) <project location>"
}

function FUNC_parse_argument(){
	for arg in $@
	do
		case "${arg}" in
			-h|--help)
				USAGE
				exit 0
				;;
		esac
	done
}

###
# main
###

# argument check

FUNC_parse_argument $@

if [[ $# != 1 ]];then
	echo "usage $(basename $0) <project location>"
	exit 1
fi

# define HOST variables
HOST_POKY_DIR="$(realpath $1)"
HOST_HOME="${HOME}"

# define DOCKER variable 
DOCKERFILE="Dockerfile"

DOCKER_IMAGE_TAG="poky-dev-env"
DOCKER_POKY_DIR=${HOST_POKY_DIR}
DOCKER_CONTAINER_NAME="${DOCKER_IMAGE_TAG}_container"
DOCKER_HOME="/home/pokyuser"

# build docker if the image doesn't exist
DOCKER_BUILD_WORKDIR=$(realpath ${0})
DOCKER_BUILD_WORKDIR=${DOCKER_BUILD_WORKDIR%/*}
FUNC_check_image_existed "${DOCKER_IMAGE_TAG}"
ret=$?


if [[ ${ret} -eq 0 ]]; then

	echo \
	"
	docker build
	-t ${DOCKER_IMAGE_TAG} 
	-f ${DOCKER_BUILD_WORKDIR}/${DOCKERFILE}
	${DOCKER_BUILD_WORKDIR}
	"
	
	docker build \
	-t ${DOCKER_IMAGE_TAG} \
	-f ${DOCKER_BUILD_WORKDIR}/${DOCKERFILE} \
	${DOCKER_BUILD_WORKDIR}

	echo "ret=$?"

fi

# create container if the container doesn't exist
# execute bash in container
FUNC_check_container_existed ${DOCKER_CONTAINER_NAME}
ret=$?

if [[ ${ret} -eq 0 ]];then

	echo \
	"
	docker run 
	-it 
	--rm
	-v ${HOST_POKY_DIR}:${DOCKER_POKY_DIR}
	-v ${HOST_HOME}/.Xauthority:${DOCKER_HOME}/.Xauthority
	-v ${HOST_HOME}/.gitconfig:${DOCKER_HOME}/.gitconfig
	-v /tmp/.X11-unix:/tmp/.X11-unix
	-p 2222:2222
	-e DISPLAY=${DISPLAY}
	--name ${DOCKER_CONTAINER_NAME} 
	${DOCKER_IMAGE_TAG}
	"
	
	docker run \
	-it \
	--rm \
	-v ${HOST_POKY_DIR}:${DOCKER_POKY_DIR} \
	-v ${HOST_HOME}/.Xauthority:${DOCKER_HOME}/.Xauthority \
	-v ${HOST_HOME}/.gitconfig:${DOCKER_HOME}/.gitconfig \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-p 2222:2222 \
	-e DISPLAY=${DISPLAY} \
	--name ${DOCKER_CONTAINER_NAME} \
	--workdir=${DOCKER_POKY_DIR} \
	${DOCKER_IMAGE_TAG} 

else 

	echo \
	"
	docker exec
	-it
	--user pokyuser
	${DOCKER_CONTAINER_NAME}
	bash
	"

	docker exec \
	-it \
	--user pokyuser \
	${DOCKER_CONTAINER_NAME} \
	bash
	
fi
