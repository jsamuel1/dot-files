#!/bin/zsh
# for autolock, have xautolock call this script

# xautolock -time 10 -locker lock.sh -enable
logo=~/Wallpapers/screensaver_logo.png

screenshot=$(mktemp --suffix=.png --tmpdir scrtmpXXXXXX)
out_logo=$(mktemp --suffix=.png --tmpdir scrtmpXXXXXX)
out_blur=$(mktemp --suffix=.png --tmpdir scrtmpXXXXXX)
out_screensaver=$(mktemp --suffix=.png --tmpdir scrtmpXXXXXX)
echo out_logo=${out_logo}
echo out_blur=${out_blur}
echo out_screensaver=${out_screensaver}

scrot -o ${screenshot}

# compute resized dimensions
width=`identify -ping -format "%w" ${screenshot}`
height=`identify -ping -format "%h" ${screenshot}`
echo dimensions=${width}x${height}

if [ -f ${logo} ]; then
  convert ${logo} -write mpr:cell +delete \
    -size ${width}x${height} tile:mpr:cell \
    -flatten ${out_logo}
else
  # create empty image to merge in
  convert -size ${width}x${height} xc:none ${out_logo}
fi

convert ${screenshot} -blur 0x7 -blue-shift 1.5 \
  -flatten ${out_blur}
composite -compose linear-burn \
  -define compose:outside-overlay=false -blend 80x20 \
  ${out_blur} ${out_logo} ${out_screensaver}

rm $screenshot
rm $out_logo
rm $out_blur

i3lock -i $out_screensaver

rm $out_screensaver
