#!/bin/bash

echo Put the CTID to change
read oldCTID
case $oldCTID in
    ''|*[!0-9]*)
        echo bad input. Exiting
        exit;;
    *)
        echo Old CTID - $oldCTID ;;
esac
echo
echo Put the new CTID
read newCTID
case $newCTID in
    ''|*[!0-9]*)
        echo bad input. Exiting
        exit;;
    *)
        echo New CTID - $newCTID ;;
esac
echo

vgNAME="$(lvs --noheadings -o lv_name,vg_name | grep $oldCTID | awk -F ' ' '{print $2}')"

case $vgNAME in
    "")
        echo Machine not in Volume Group. Exiting
        exit;;
    *)
        echo Volume Group - $vgNAME ;;
esac

oldDISK="$(lvs --noheadings -o lv_name,vg_name | grep $oldCTID | awk -F ' ' '{print $2}')"

for i in $(lvs -a|grep $vgNAME | awk '{print $1}' | grep $oldCTID);
do lvrename $vgNAME/vm-$oldCTID-disk-$(echo $i | awk '{print substr($0,length,1)}') vm-$newCTID-disk-$(echo $i | awk '{print substr($0,length,1)}');
done;
sed -i "s/$oldCTID/$newCTID/g" /etc/pve/lxc/$oldCTID.conf;
mv /etc/pve/lxc/$oldCTID.conf /etc/pve/lxc/$newCTID.conf;

echo Ta-Da! We renamed the CT $oldCTID to $newCTID.
