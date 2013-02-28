#!/bin/bash
 
# This is a sample script for kickstarting a VM according to the openshift.ks 
# script under virt-manager, qemu+KVM, and Linux.

set -e
 
if [ $# -lt 1 ]
then
  printf 'Usage: %s vm_name [arg1 [arg2 [...]]]\n' "$0"
  printf 'Example:\n'
  printf '%s OpenShiftOrigin-BrokerAndNode install_components=broker,node,activemq,datastore named_ip_addr=10.0.0.1' "$0"
  exit 1
fi
 
image_name="$1"; shift
image_path=/opt/"$image_name"
 
kickstart_args='ks=https://raw.github.com/maxamillion/openshift-extras/fedora-18/origin/install-scripts/openshift.ks'
for arg
do
  kickstart_args="$kickstart_args $arg"
done
 
set -x
 
qemu-img create "$image_path" 15G -f raw
parted "$image_path" mklabel msdos
parted --align optimal "$image_path" mkpart primary ext4 1M 15G
mkfs.ext4 -F "$image_path"
 
virt-install --name="$image_name" --ram=2048 --vcpus=2 --hvm \
  --disk "$image_path" --graphics spice -d --wait=-1 --autostart \
  --location http://mirrors.kernel.org/fedora/releases/18/Fedora/x86_64/os/ \
  -x "$kickstart_args" --connect qemu:///system --network network=default
