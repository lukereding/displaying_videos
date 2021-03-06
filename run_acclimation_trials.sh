#!/usr/bin/env bash

## for the acclimation trials before mate choice trials start
# assumes you're logged onto mini2
VOICE=(
    'Samantha'
    'Kathy'
    'Karen'
    'Bruce'
    'Alex'
    'Bad News'
)
#pick a random voice
rand=$[ $RANDOM % ${#VOICE[@]} ]
RANDOM_VOICE=${VOICE[$rand]}
LENGTH_OF_VIDEOS=7200

mini1=lukereding@128.83.192.234

echo -e "this script runs the background video, which should be 2 hours long, on all three screens\n\nthe script will email you when it is done"

# do you want to record the acclimation?
while true; do
    read -p "type Y if you want to record a video of the trial; otherwise type N." yn
    case $yn in
        [Yy]* ) echo recording the trial; record=yes; break;;
        [Nn]* ) echo not recording the trial; record=no; break;;
        * ) echo "type y or n";;
    esac
done

# start the trial
say -v $RANDOM_VOICE "Pressing Y and Enter on the keyboard will start the acclimation for 2 hours."

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

# ask mini1 to record:
if [ "$record" == "yes" ]; then
    echo "sleep 14; ffmpeg -f avfoundation -video_size 1280x720 -framerate 10 -i "Micro:none" -crf 28 -vcodec libx264 -y -t "$LENGTH_OF_VIDEOS" ~/Desktop/acclimation_trials/"`date "+%Y.%m.%d.%H.%M.%S"`"".avi" || echo "video failed"" | ssh $mini1 /bin/bash &
fi

# show the background120min.mp4 video on all three screens
echo "cd `pwd` && python show_vid.py -v1 background120min.mp4 -t "$START_TIME"" | ssh $mini1 /bin/bash &
python show_vid.py -v1 background120min.mp4 -v2 background120min.mp4 -t "$START_TIME" &

wait

# email
echo "the acclimation trial is over at `date`" | mail -s "acclimation trial over!" lukereding@gmail.com

say -v $RANDOM_VOICE "The acclimation trial is over. Exiting the program now. Smell you later."

echo "acclimation trial over. exiting."

exit 0
