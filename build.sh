#!/bin/bash

[ ! -f linux/include/linux/version.h ] && {
echo Prepare building
pushd linux 1> /dev/null 

i386 ./01-PREPARE.sh gcc 
make include/linux/compile.h 
make HOSTCC=tcc TOPDIR=`pwd` -C drivers/pci devlist.h 
tar xzf ../addon.tgz

popd 1> /dev/null
}

cd bin
[ ! -f bzImage ] && {
echo Build bbootsect
gcc -I../linux/include -MMD -mno-red-zone -mcmodel=kernel -fno-pie -Wa,--divide -c -o bootsect.o ../linux/arch/i386/boot/bootsect.S
ld -Ttext=0 --oformat=binary -o bbootsect bootsect.o

echo Build bsetup
gcc -I../linux/include  -D__ASSEMBLY__ -D__KERNEL__ -D__BIG_KERNEL__ -c -o bsetup.o ../linux/arch/i386/boot/setup.S
ld -Ttext=0 --oformat=binary -e begtext -o bsetup bsetup.o

echo Build build
tcc -I../linux/include ../linux/arch/i386/boot/tools/build.c -o build

rm *.o bootsect.d
}

echo Building kernel

. ../head.inc

if [ -n "$(echo $CC | grep tcc)" ]; then
    CC="$CC -bench"
fi

echo CC=$CC

#-iwithprefix include

CC="$CC \
-o $KERNEL \
-nostdlib -static -Wl,-Ttext,0xc0100000 -Wl,--oformat,binary  \
-nostdinc  -I../linux/include \
-D__KERNEL__ -D__OPTIMIZE__ "

echo $CC

$CC \
$FILE_LIST_1 \
$FILE_LIST_2 \
$FILE_LIST_3 \
$FILE_LIST_4 \
$FILE_LIST_5 \
$CCLIB 2>&1 | tee LOG

. ../tail.inc

