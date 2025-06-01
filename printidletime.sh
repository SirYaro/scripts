#!/bin/bash

ACT_AS_USER="foo"

OUT="/tmp/${ACT_AS_USER}-idle-time"
export DISPLAY=:0
IDLE_MS=$(sudo -u ${ACT_AS_USER} xprintidle)

echo "scale=0;(${IDLE_MS}+250)/1000" | bc | tr -d '\n' | tee ${OUT}
