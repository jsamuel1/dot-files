#!/bin/sh

if command -v xautolock; then
   xautolock -time 10 -locker lock.sh &
fi

