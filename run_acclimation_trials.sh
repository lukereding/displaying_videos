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
rand1=$[ $RANDOM % ${#VOICE[@]} ]
RANDOM_VOICE=${VOICE[$rand]}

mini1=lukereding@128.83.192.234

echo -e "this script runs the background video, which should be 60 minutes long, on all three screens\n\n"

# do you want to record the acclimation?
while true; do
    read -p "type Y if you want to record a video of the trial; otherwise type N." ny
    case $ny in
        [Yy]* ) echo -e "\n\nok, I'll record the trial."; record=yes; break;
        [Nn]* ) echo "\n\na video of this acclimation will not recorded."; record=no; break;
        * ) echo "type y or n";;
    esac
done

# ask mini1 to record:
if [ "$record" == "yes" ]; then
    echo "sleep 14; ffmpeg -f avfoundation -video_size 1280x720 -framerate 10 -i "Micro:none" -crf 28 -vcodec libx264 -y -t "$LENGTH_OF_VIDEOS"  ~/Desktop/acclimation_trials/"`date "+%Y-%m-%d-%H:%M:%S"`"".avi" || echo "video failed"" | ssh $mini1 /bin/bash &
fi

# start the trial

say -v $RANDOM_VOICE "Pressing Y and Enter on the keyboard will start the acclimation for 1 hour."

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

say -v $RANDOM_VOICE "The acclimation trial is over. Exiting the program now. Smell you later."

echo "acclimation trial over. exiting."

exit 0