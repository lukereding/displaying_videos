#!/usr/bin/env bash

# I use this script to run IIA trials
# it asks the user for useful things, runs scripts that need to be run, etc.
# it appends line to a log file that log the temperature of thank tank, female's name, etc.
# I am emailed whenever an error is generated or at the end of trial trial

# to do:
## check log file to make sure the female / trial type combination hasn't been made yet

# define location of log file for the trials and the user name and ip address of the second computer
LOG_FILE="/Users/lukereding/Desktop/results.log"
mini1=lukereding@128.83.192.234
date=`date`
LENGTH_OF_VIDEOS=1260

# for when the computer talks to you
VOICE=(
    'Samantha'
    'Kathy'
    'Karen'
    'Bruce'
    'Alex'
)
#pick a random voice
rand=$[ $RANDOM % ${#VOICE[@]} ]
RANDOM_VOICE=${VOICE[$rand]}

# what do to if the user hits control +c during the script execution
# trap ctrl-c and call ctrl_c()
trap 'killall' INT
# kill all python processes and all processes spawned by this script
killall() {
    trap '' INT TERM     # ignore INT and TERM while shutting down
    echo "**** Shutting down... ****"     # added double quotes
    kill -TERM 0         # fixed order, send TERM not INT
    # kill process on second computer
    echo "kill $(ps aux | grep 'python' | awk '{print $2}')" | ssh $mini1 /bin/bash
    wait
    say "you've killed the trial. damn."
    echo TRIAL KILLED
    exit
}

# function to read in a test file as an array. from http://stackoverflow.com/questions/20294918/extract-file-contents-into-array-using-bash-scripting
getArray() {
    array=() # Create array
    while IFS= read -r line # Read a line
    do
        array+=("$line") # Append line to the array
    done < "$1"
}

# explain what's going on to the user
echo -e "\n\nthere are a couple of steps to using this program\n\nfirst you'll be asked to enter in some basic information about the trial. The script will randomly determine which videos get sent to which monitor.\n\nThe script will then automatically start running the videos and the recording the video for tracking analysis later.\n\nWhen the trial is over, you will be prompted to enter in some more information about the fish, like its weight. Once you do this the trial is logged in a log file stored here: $LOG_FILE. At that point, the script will exit and you can start a new trial.\n\n\n"

say -v $RANDOM_VOICE "time to get this party started"

# have the user enter in basic information about the trial
echo -e "name of female:\t \c "
read female
say -v $RANDOM_VOICE "cool. You are testing $female"
echo -e "water temperature in the tank:\t \c "
read temperature
while [[ $temperature == *[!0-9.]* ]]; do
    echo "you typed in "$temperature" for the temperaure. please try typing it in again using only numbers and periods:"
    read temperature
done

say -v $RANDOM_VOICE "the temperature is "$temperature" degrees."

echo -e "your name?:\t \c "
read observer

say -v $RANDOM_VOICE "hi "$observer""

# find out if there is a file called trinary_male_list; if not, create it
if [ ! -f trinary_male_list ]; then
    echo -e "large_vs_largeDecoy_trinary\nlargeDecoy_vs_small_trinary\nsmall_vs_large_trinary" > trinary_male_list
fi

# find out whether this trial is binary or trinary
while true; do
    read -p "Binary or trinary trial? Type in 'b' or 't' and then press enter." bt
    case $bt in
        [Bb]* ) echo "binary trial "; trial_type='binary'; break;;
        [Tt]* ) echo "trinary trial"; trial_type='trinary'; break;;
        * ) echo "Please answer b or t.";;
    esac
done

say -v $RANDOM_VOICE "$trial_type trial."

# find out whether this trial is redo or not
while true; do
    read -p "Is this a redo trial? Type in 'y' or 'n' and then press enter." yn
    case $yn in
        [Yy]* ) echo "it's a redo "; redo='redo'; break;;
        [Nn]* ) echo "first time"; redo=''; break;;
        * ) echo "Please answer y or n.";;
    esac
done

# randomize which video goes to what monitor
if [ "$trial_type" == "binary" ]; then
    array=( $(echo "small_vs_large_binary;large_vs_small_binary" | sed 's,([^;]\(*\)[;$]),\1,g' | tr ";" "\n" | gshuf | tr "\n" " " ) )
    left_screen=${array[0]}
    right_screen=${array[1]}
    middle_screen="NULL"
    echo left screen: $left_screen && echo right screen: $right_screen
elif [  "$trial_type" == "trinary" ]; then
    # rotate the which male appears where by one (i.e. everyone moves 1 monitor to the left)
    echo "`tail -1 trinary_male_list && head -2 trinary_male_list`" > trinary_male_list
    # read in the resulting file as an array
    getArray "trinary_male_list"
    left_screen=${array[0]}
    right_screen=${array[1]}
    middle_screen=${array[2]}
    echo right screen: $right_screen && echo middle screen: $middle_screen && echo left screen: $left_screen
else
    echo "trial_type variable is not properly assigned"
    exit 1
fi

# error checking
if [ $? -gt 0 ]; then
  echo "randomization of videos failed. aborting."
  echo -e "randomization of videos failed.\n\n" | mail -s "aborting script" lukereding@gmail.com
  exit 1
fi

SECONDS=`date +%s`
START_TIME=$(( SECONDS + 15 ))

echo -e \n\ntrial will begin at at `date -r $SECONDS '+%H:%M:%S'`\n\n

# execute the python code and wait
if [ "$trial_type" == "binary" ]; then
    # show middle screen video as the background image
    echo "cd `pwd` && python show_vid.py -v1 background.mp4 -t "$START_TIME"" | ssh $mini1 /bin/bash &
    # show the male videos
    python show_vid.py -v1 "$left_screen"".mp4" -v2 "$right_screen"".mp4" -t "$START_TIME" &
    # record the trial
    echo "sleep 14; ffmpeg -f avfoundation -video_size 1280x720 -framerate 10 -i "Micro:none" -crf 28 -vcodec libx264 -y -t "$LENGTH_OF_VIDEOS"  ~/Desktop/"$female"_"$trial_type"_"$redo"".avi" || echo "video failed"" | ssh $mini1 /bin/bash &
    say "make sure the blue light comes on in, like, 10 seconds."
    wait
else
    # show middle screen video
    echo "cd `pwd` && python show_vid.py -v1 "$middle_screen"".mp4" -t "$START_TIME"" | ssh $mini1 /bin/bash &
    # show the two other videos
    python show_vid.py -v1 "$left_screen"".mp4" -v2 "$right_screen"".mp4" -t "$START_TIME" &
    # record the trial
    ## TESTING THIS LINE
    echo "sleep 14; ffmpeg -f avfoundation -video_size 1280x720 -framerate 10 -i "Micro:none" -crf 28 -vcodec libx264 -y -t "$LENGTH_OF_VIDEOS" ~/Desktop/"$female"_"$trial_type"_"$redo"".avi" || echo "video failed"" | ssh $mini1 /bin/bash &
    # ssh $mini1 python show_vid.py -v1 "$middle_screen"".mp4" &
    #ssh $mini1 cd ~/Documents/displaying_videos/; python show_vid.py -v1 "$middle_screen"".mp4" &
    say "make sure the blue light on the webcam comes on in like, 10 seconds."
    wait
fi

if [ $? -gt 0 ]; then
  echo "problem with python script"
  echo "python script failed at `date`" | mail -s "python script failed" lukereding@gmail.com
  echo "problem with the python script."
  exit 1
fi

# after trial is over, get the size of the fish
say -v $RANDOM_VOICE "the trial is over. please check and make sure this information is correct."

# email the user to let them know the trial is over.

echo the trial is over | mail -s "the trial is over" lukereding@gmail.com
if echo $observer | grep -iq Aurelia; then
    echo the trial is over | mail -s "the trial is over" aurelia.a.allen@utexas.edu
else
    echo the trial is over | mail -s "the trial is over" lukereding@gmail.com
fi

# repeat the trial information back to the user, make sure everything looks good
echo -e "here's what you entered:\n\n"
echo -e "female\tdate\t\t\t\ttemperature\t\tobserver\ttrial_type\tleft_screen\tright_screen\tmiddle_screen"
echo -e "$female\t$date\t$temperature\t$observer\t$trial_type\t$left_screen\t$right_screen\t$middle_screen"

# ask the user to verify the information
while true; do
    read -p "If all that looks good to you, press 'y'. Otherwise, press 'n' and make a note of the error." yn
    case $yn in
        [Yy]* ) echo "it checks out "; looks_good='yes'; break;;
        [Nn]* ) echo "please make a note of the error"; looks_good='no'; break;;
        * ) echo "Please type 'y' or 'n'";;
    esac
done


# save a log file of the trial
#append row if the file already exists
if [ -f $LOG_FILE ]; then
    echo "$female,$date,$temperature,$observer,$trial_type,$left_screen,$right_screen,$middle_screen,$redo,$looks_good" >> $LOG_FILE
else
    # then it's the first trial first trial --
    echo "female,date,temperature,observer,trial_type,left_screen,right_screen,middle_screen,redo,looks_good" > $LOG_FILE
    echo "$female,$date,$temperature,$observer,$trial_type,$left_screen,$right_screen,$middle_screen,$redo,$looks_good" > $LOG_FILE
fi

# email the log file to yourself for save-keeping
cat $LOG_FILE | mail -s "log file: `date`" lukereding@gmail.com

# Log errors if the file doesn't send
if [ $? -gt 0 ]; then
  echo -e "\n\n\n\tFailed to email log file. Let Luke know.\n\n"
  echo "Failed to email log file" | mail -s "failed to email log file" lukereding@gmail.com
  say -v $RANDOM_VOICE "shit. log file couldn't send. make a note."
  exit 1
fi

echo -e "\n\n\n\n\tthe script is done running. everything went according to plan."

say -v $RANDOM_VOICE "trial ended."

exit 0
