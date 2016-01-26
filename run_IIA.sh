#!/usr/bin/env bash

# define location of log file for the trials
LOG_FILE="/Users/lukereding/Desktop/results.log"

# optional, if you create a separate account on your computer:
#test "$(whoami)" != 'student' && (echo try again logged in as a student; exit 1)
# then you can get rid of the observer read in line below

# explain what's going on to the user
echo "\n\nthere are a couple of steps to using this program\n\nfirst you'll be asked to enter in some basic information about the trial. The script will randomly determine which videos get sent where based on the information you provide.\n\nThe script will then automatically start running the videos and the recording the video for tracking analysis later.\n\nWhen the trial is over, you will be prompted to enter in some more information about the fish, like its weight. Once you do this the trial is logged in a log file stored here: $LOG_FILE. At that point, the script will exit and you can start a new trial."


# have the user enter in basic information about the trial
echo "name of female:\t \c "
read female
echo "water temperature in the tank:\t \c "
read temperature
echo "your name?:\t \c "
read observer

# find out whether this trial is binary or trinary
while true; do
    read -p "Binary (b) or trinary (t) trial?\t" bt
    case $bt in
        [Bb]* ) echo "binary trial "; trial_type=binary; break;;
        [Tt]* ) echo "trinary trial"; trial_type=trinary; break;;
        * ) echo "Please answer b or t.";;
    esac
done

# randomize which video goes to what monitor
if [ "$trial_type" == "binary" ]; then
    array=( $(echo "small;large" | sed 's,([^;]\(*\)[;$]),\1,g' | tr ";" "\n" | gshuf | tr "\n" " " ) )
    left_screen=${array[0]}
    right_screen=${array[1]}
    middle screen="NULL"
elif [ "$trial_type" == "trinary" ]; then
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
  echo "randomization of videos failed.\n\nthe script was run for $SECONDS seconds" | mail -s "aborting script" lukereding@gmail.com
  exit 1
fi

# save a log file of the trial
#append row if the file already exists
if [ -f $LOG_FILE ]; then
    echo "$female,`date`,$temperature,$observer,$trial_type,$left_screen,$right_screen,$middle_screen" >> $LOG_FILE
else
    # then it's the first trial first trial --
    echo "female,date,temperature,observer,trial_type,left_screen,right_screen,middle_screen" > $LOG_FILE
    echo "$female,`date`,$temperature,$observer,$trial_type,$left_screen,$right_screen,$middle_screen" > $LOG_FILE
fi

# execute the python code and wait
# python display_video $left_screen $right_screen $ middle_screen ...; wait

# after trial is over, get the size of the fish
echo "weight of female in grams: \c "
read weight
echo "the female weighs $weight grams."

# email the log file to yourself for save-keeping
cat $LOG_FILE | mail -s "log file: `date`" lukereding@gmail.com

# Log errors if the file doesn't send
if [ $? -gt 0 ]; then
  echo "Failed to email log file"
  echo "Failed to email log file" | mail -s "failed to email log file" lukereding@gmail.com
  exit 1
fi

echo "\n\n\n\nthe script is done running. everything went according to plan."

exit 0
