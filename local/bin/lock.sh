#!/bin/sh
# for autolock, have xautolock call this script:
# xautolock -time 10 -locker lock.sh -enable
scrot /tmp/screenshot.png
convert /tmp/screenshot.png -blur 0x7 -blue-shift 1.5 /tmp/screenshotblur.png
rm /tmp/screenshot.png
i3lock -i /tmp/screenshotblur.png

