#!/bin/bash
set -e
cd $(dirname $0)

export LIBGUESTFS_BACKEND=direct

##############################################################################
ORIGIN_IMAGE_NAME="CentOS-7-x86_64-GenericCloud-2009.qcow2"
TARGET_IMAGE_NAME="customize_CentOS-7_"`date +%Y%m%d`".qcow2"

CLOUD_IMAGE_SERVER="https://cloud.centos.org/centos/7/images/"

##############################################################################
function log_info() {
    CURTIME=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "\033[1;32m[${CURTIME}] $1\033[0m"
}
function log_err() {
    echo -e "\033[1;35mERR> $1\033[0m"
}
##############################################################################
log_info "Start!"

## 1.Download Offical Cloud Images
if [ ! -f  ${ORIGIN_IMAGE_NAME} ] ; then
  log_info "Downloading [${ORIGIN_IMAGE_NAME}]..."
  wget -q "${CLOUD_IMAGE_SERVER}${ORIGIN_IMAGE_NAME}"
fi

## 2. Image Backup
rm -f ${TARGET_IMAGE_NAME}
cp ${ORIGIN_IMAGE_NAME} ${TARGET_IMAGE_NAME} 


## 3. customize the virtual machine with config file
log_info "customizing the virtual machine ..."
virt-sysprep -a uncompressed_${TARGET_IMAGE_NAME} --network --commands-from-file config/customize_cmd_lines.txt


## 4.compresse qcow2 image
log_info "compressing the qcow2 image ..."
qemu-img convert -c -O qcow2 uncompressed_${TARGET_IMAGE_NAME} ${TARGET_IMAGE_NAME}
rm -f uncompressed_${TARGET_IMAGE_NAME}
log_info "End!"
