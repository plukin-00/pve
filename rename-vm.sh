#!/bin/bash

echo Put the VMID to change
read oldVMID
case $oldVMID in
    ''|*[!0-9]*)
        echo bad input. Exiting
        exit;;
    *)
        echo Old VMID - $oldVMID ;;
esac
echo
echo Put the new VMID
read newVMID
case $newVMID in
    ''|*[!0-9]*)
        echo bad input. Exiting
        exit;;
    *)
        echo New VMID - $newVMID ;;
esac
echo

vgNAME="$(lvs --noheadings -o lv_name,vg_name | grep $oldVMID | awk -F ' ' '{print $2}')"

case $vgNAME in
    "")
        echo Machine not in Volume Group. Exiting
        exit;;
    *)
        echo Volume Group - $vgNAME ;;
esac

for i in $(lvs -a|grep $vgNAME | awk '{print $1}' | grep $oldVMID);
do lvrename $vgNAME/vm-$oldVMID-disk-$(echo $i | awk '{print substr($0,length,1)}') vm-$newVMID-disk-$(echo $i | awk '{print substr($0,length,1)}');
done;
sed -i "s/$oldVMID/$newVMID/g" /etc/pve/qemu-server/$oldVMID.conf;
mv /etc/pve/qemu-server/$oldVMID.conf /etc/pve/qemu-server/$newVMID.conf;

echo Ta-Da! We renamed the CT $oldVMID to $newVMID.
