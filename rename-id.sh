#!/bin/bash

clear
echo Put the $1 ID to change
read oldID
case $oldID in
    ''|*[!0-9]*)
        echo bad input. Exiting
        exit 0;;
    *)
        echo Old ID - $oldID ;;
esac
echo
echo Put the new $1 ID
read newID
case $newID in
    ''|*[!0-9]*)
        echo bad input. Exiting
        exit 0;;
    *)
        echo New ID - $newID ;;
esac
echo

vgNAME="$(lvs --noheadings -o lv_name,vg_name | grep $oldID | awk -F ' ' '{print $2}')"

case $vgNAME in
    "")
        echo Machine not in Volume Group. Exiting
        exit 0;;
    *)
        echo Volume Group - $vgNAME ;;
esac



if [[ $1 -eq "ct" || $1 -eq "CT" ]]; then
	for i in $(lvs -a|grep $vgNAME | awk '{print $1}' | grep $oldID);
	do lvrename $vgNAME/vm-$oldID-disk-$(echo $i | awk '{print substr($0,length,1)}') vm-$newID-disk-$(echo $i | awk '{print substr($0,length,1)}');
	done;
	sed -i "s/$oldID/$newID/g" /etc/pve/lxc/$oldID.conf;
	mv /etc/pve/lxc/$oldID.conf /etc/pve/lxc/$newID.conf;
elif [[ $1 -eq "vm" || $1 -eq "VM" ]]; then
	for i in $(lvs -a|grep $vgNAME | awk '{print $1}' | grep $oldVMID);
	do lvrename $vgNAME/vm-$oldVMID-disk-$(echo $i | awk '{print substr($0,length,1)}') vm-$newVMID-disk-$(echo $i | awk '{print substr($0,length,1)}');
	done;
	sed -i "s/$oldID/$newID/g" /etc/pve/qemu-server/$oldID.conf;
	mv /etc/pve/qemu-server/$oldID.conf /etc/pve/qemu-server/$newID.conf;
else
	exit 0
fi

echo Ta-Da! We renamed the $1 $oldID to $newID.
