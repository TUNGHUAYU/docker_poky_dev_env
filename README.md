# docker_poky_dev_env
run docker container with poky-development-ready environment



## Clone poky by Git 

```bash
$ git clone git://git.yoctoproject.org/poky ${POKY_DIR}
$ cd ${POKY_DIR}
$ git checkout -t origin/kirkstone -b my-kirkstone
$ git pull
```



## Setup development environment by docker

```bash
# Enter a docker container for poky-development-ready environment with the following commands:
$ bash run_container.sh ${POKY_DIR}
```



## Build poky image

please replacing the following content in `conf/local.conf`

```bash
BB_SIGNATURE_HANDLER = "OEEquivHash"
BB_HASHSERVE = "auto"
BB_HASHSERVE_UPSTREAM = "hashserv.yocto.io:8687"
SSTATE_MIRRORS ?= "file://.* https://sstate.yoctoproject.org/all/PATH;downloadfilename=PATH"
```



build image:

```bash
$ cd poky
$ source oe-init-build-env
$ bitbake core-image-minimal
```



## Reference:

- website - Yocto Project Quick Build 
  https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html
