#!/bin/bash
URI="qemu:///system"

for vm in $(virsh -c $URI list --name); do
  virsh -c qemu:///system shutdown "$vm"
done

while [ -n "$(virsh -c "$URI" list --name)" ]; do
  sleep 1
done

doas rc-service libvirtd restart

for vm in $(virsh -c $URI list --all --name); do
  if [[ "$vm" != *win10* ]]; then
    virsh -c qemu:///system start "$vm"
  fi
done
