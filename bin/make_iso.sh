#!/bin/bash
# ---------------------------------------------------
# Script to create bootable ISO in Linux
# usage: make_iso.sh [ /tmp/fantoo.iso ]
# author: Tomas M. <http://www.linux-live.org>
# ---------------------------------------------------
# Fantoo modifications:
#  * use grub as boot loader insteed of isolinux
#  * allow long file names (iso-level 4)
#  * no Joilet
#  * no images, changes,... to iso

if [ "$1" = "--help" -o "$1" = "-h" ]; then
  echo "This script will create bootable ISO from files in curent directory."
  echo "Current directory must be writable."
  echo "example: $0 /mnt/hda5/fantoo.iso"
  exit
fi

MKISOFS=`which mkisofs`
if [ -z "$MKISOFS" ]; then
    echo "WARNING: mkisofs not found, image not created"
    exit
fi

CDLABEL="TCCBOOT"
ISONAME=./tccboot.iso

echo
echo "ISO file name:	$ISONAME"
echo

[ -f "boot/grub/stage2_eltorito.boot" ] && {
    rm boot/grub/stage2_eltorito.boot
}

[ -f "$ISONAME" ] && {
    rm $ISONAME
}

cat initrd |gzip > initrd.ext2.gz

mkisofs \
   -o "$ISONAME" \
   -V "$CDLABEL" \
   -iso-level 4 \
   -R -D \
   -no-emul-boot -boot-info-table -boot-load-size 4 \
   -b boot/grub/stage2_eltorito -c boot/grub/stage2_eltorito.boot \
   -graft-points \
    boot=boot \
    make_iso.sh=make_iso.sh \
    READNE=README \
    bzImage=bzImage \
    initrd.ext2.gz=initrd.ext2.gz

