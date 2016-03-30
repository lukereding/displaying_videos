#!/usr/bin/env bash

## for the acclimation trials before mate choice trials start
# assumes you're logged onto mini2


mini1=lukereding@128.83.192.234

echo -e "this script runs the background video, which should be 60 minutes long, on all three screens\n\n"


echo -e "type Y when you're ready to begin the acclimation:\t \c "
while true; do
    read -p "type Y then press Enter when you're ready to begin the acclimation:." y
    case $y in
        [Yy]* ) echo "starting... "; break;;
        * ) echo "Please answer y when you're ready to start.";;
    esac
done

SECONDS=`date +%s`
START_TIME=$(( SECONDS + 15 ))

echo acclimation will begin at at `date -r $START_TIME '+%H:%M:%S'`

# show the background60min/mp4 video on all three screens
echo "cd `pwd` && python show_vid.py -v1 background60min.mp4 -t "$START_TIME"" | ssh $mini1 /bin/bash &
python show_vid.py -v1 background60min.mp4 -v2 background60min.mp4 -t "$START_TIME" &

wait

echo "acclimation trial over. exiting."

exit 0

