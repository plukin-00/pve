#!/bin/bash

clear
echo Put the ID to change
read oldID
case $oldID in
    ''|*[!0-9]*)
	echo bad input. Exiting
	exit 0;;
    *)
	echo Old ID - $oldID ;;
esac
echo
echo Put the new ID
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

if [[ -n $(qm list | grep 301) ]]; then
        type="vm"
elif [[ -n $(pct list | grep 301) ]]; then
        type="lxc"
else
        type="error getting typ"
        exit 0
fi

if [[ $type == "lxc" ]]; then
	echo rename LXC
	for i in $(lvs -a|grep $vgNAME | awk '{print $1}' | grep $oldID);
	do lvrename $vgNAME/vm-$oldID-disk-$(echo $i | awk '{print substr($0,length,1)}') vm-$newID-disk-$(echo $i | awk '{print substr($0,length,1)}');
	done;
	sed -i "s/$oldID/$newID/g" /etc/pve/lxc/$oldID.conf;
	mv /etc/pve/lxc/$oldID.conf /etc/pve/lxc/$newID.conf;
elif [[ $type == "vm" ]]; then
	echo rename VM
	for i in $(lvs -a|grep $vgNAME | awk '{print $1}' | grep $oldVMID);
	do lvrename $vgNAME/vm-$oldID-disk-$(echo $i | awk '{print substr($0,length,1)}') vm-$newID-disk-$(echo $i | awk '{print substr($0,length,1)}');
	done;
	sed -i "s/$oldID/$newID/g" /etc/pve/qemu-server/$oldID.conf;
	mv /etc/pve/qemu-server/$oldID.conf /etc/pve/qemu-server/$newID.conf;
else
	echo argument missing (vm/lxc)
	exit 0
fi

echo We renamed the $type from $oldID to $newID.
