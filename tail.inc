# bash

[ -f "$KERNEL" ] && {
    echo "step B: build" 
    ./build -b ./bbootsect ./bsetup $KERNEL CURRENT > $KERNEL_BOOT
    #rm "$KERNEL"
    ./make_iso.sh
    exit 0
}

echo "error: compilation failed" | tee -a LOG
exit 1
