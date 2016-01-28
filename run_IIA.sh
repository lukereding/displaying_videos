#!/usr/bin/env bash

# I use this script to run IIA trials
# it asks the user for useful things, runs scripts that need to be run, etc.
# it appends line to a log file that log the temperature of thank tank, female's name, etc.
# I am emailed whenever an error is generated or at the end of trial trial

# define location of log file for the trials and the user name and ip address of the second computer
LOG_FILE="/Users/lukereding/Desktop/results.log"
mini1=lukereding@10.146.163.170
date=`date`

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
    echo DONE
    exit
}

# explain what's going on to the user
echo -e "\n\nthere are a couple of steps to using this program\n\nfirst you'll be asked to enter in some basic information about the trial. The script will randomly determine which videos get sent to which monitor.\n\nThe script will then automatically start running the videos and the recording the video for tracking analysis later.\n\nWhen the trial is over, you will be prompted to enter in some more information about the fish, like its weight. Once you do this the trial is logged in a log file stored here: $LOG_FILE. At that point, the script will exit and you can start a new trial.\n\n\n"

# have the user enter in basic information about the trial
echo -e "name of female:\t \c "
read female
echo -e "water temperature in the tank:\t \c "
read temperature
echo -e "your name?:\t \c "
read observer

# find out whether this trial is binary or trinary
while true; do
    read -p "Binary (b) or trinary (t) trial?" bt
    case $bt in
        [Bb]* ) echo "binary trial "; trial_type='binary'; break;;
        [Tt]* ) echo "trinary trial"; trial_type='trinary'; break;;
        * ) echo "Please answer b or t.";;
    esac
done

echo trial -- $trial_type

# randomize which video goes to what monitor
if [ "$trial_type" == "binary" ]; then
    array=( $(echo "small;large" | sed 's,([^;]\(*\)[;$]),\1,g' | tr ";" "\n" | gshuf | tr "\n" " " ) )
    left_screen=${array[0]}
    right_screen=${array[1]}
    middle_screen="NULL"
elif [  "$trial_type" == "trinary" ]; then
    array=( $(echo "small;large;decoy" | sed 's,([^;]\(*\)[;$]),\1,g' | tr ";" "\n" | gshuf | tr "\n" " " ) )
    left_screen=${array[0]}
    right_screen=${array[1]}
    middle_screen=${array[2]}
else
    echo "trial_type variable is not properly assigned"
    exit 1
fi

# error checking
if [ $? -gt 0 ]; then
  echo "randomization of videos failed. aborting."
  echo -e "randomization of videos failed.\n\nthe script was run for $SECONDS seconds" | mail -s "aborting script" lukereding@gmail.com
  exit 1
fi

# execute the python code and wait
if [ "$trial_type" == "binary" ]; then
    python show_vid.py -v1 "$left_screen"".mp4" -v2 "$right_screen"".mp4" &
    echo $!
    wait
else
    echo "cd `pwd` && sleep 10 && python show_vid.py -v1 "$middle_screen"".mp4"" | ssh $mini1 /bin/bash &
    sleep 10 && python show_vid.py -v1 "$left_screen"".mp4" -v2 "$right_screen"".mp4" &
    echo $!
    # ssh $mini1 python show_vid.py -v1 "$middle_screen"".mp4" &
    #ssh $mini1 cd ~/Documents/displaying_videos/; python show_vid.py -v1 "$middle_screen"".mp4" &
    wait
fi

if [ $? -gt 0 ]; then
  echo "problem with python script"
  echo "python script failed at `date`" | mail -s "python script failed" lukereding@gmail.com
  exit 1
fi

# after trial is over, get the size of the fish
echo -e "weight of female in grams: \c "
read weight

# repeat the trial information back to the user, make sure everything looks good
echo -e "here's what you entered:\n\n"
echo -e "female\tdate\ttemperature\tobserver\ttrial_type\tleft_screen\tright_screen\tmiddle_screen"
echo "$female\t$date\t$temperature\t$observer\t$trial_type\t$left_screen\t$right_screen\t$middle_screen"

# ask the user to verify the information
while true; do
    read -p "If all that looks good to you, press 'y'. Otherwise, press 'n' and make a note of the error." yn
    case $yn in
        [Yy]* ) echo "it checks out "; looks_good='yes'; break;;
        [Nn]* ) echo "please make a note of the error"; loos_good='no'; break;;
        * ) echo "Please type 'y' or 'n'";;
    esac
done


# save a log file of the trial
#append row if the file already exists
if [ -f $LOG_FILE ]; then
    echo "$female,`date`,$temperature,$observer,$trial_type,$left_screen,$right_screen,$middle_screen,$looks_good" >> $LOG_FILE
else
    # then it's the first trial first trial --
    echo "female,date,temperature,observer,trial_type,left_screen,right_screen,middle_screen,looks_good" > $LOG_FILE
    echo "$female,`date`,$temperature,$observer,$trial_type,$left_screen,$right_screen,$middle_screen,$looks_good" > $LOG_FILE
fi

# email the log file to yourself for save-keeping
cat $LOG_FILE | mail -s "log file: `date`" lukereding@gmail.com

# Log errors if the file doesn't send
if [ $? -gt 0 ]; then
  echo "Failed to email log file. Let Luke know."
  echo "Failed to email log file" | mail -s "failed to email log file" lukereding@gmail.com
  exit 1
fi

echo -e "\n\n\n\nthe script is done running. everything went according to plan."

exit 0