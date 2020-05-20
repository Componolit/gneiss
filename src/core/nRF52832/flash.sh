#/bin/sh

set -e

for d in $(ls /dev/sd* | sed "s#/dev/##g;s#[0-9]##g" | uniq)
do
    if [ $(cat /sys/block/$d/device/vendor) = "SEGGER" ]
    then
        DEVICE=$d
        break
    fi
done

if [ -z "$DEVICE" ]
then
    echo no device found
    exit 1
fi

echo found device at /dev/$DEVICE

TARGET=$(udisksctl mount -b /dev/$DEVICE | sed "s/.*at[[:space:]]//g" | rev | sed "s/\.//g" | rev)

echo mounted at $TARGET

/usr/share/python3-intelhex/bin2hex.py $1 $TARGET/program.hex

