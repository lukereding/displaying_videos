#!/usr/bin/env bash

# define location of log file for the trials
LOG_FILE="/Users/lukereding/Desktop/results.log"

# optional, if you create a separate account on your computer:
#test "$(whoami)" != 'student' && (echo try again logged in as a student; exit 1)
# then you can get rid of the observer read in line below

# have the user enter in basic information about the trial
echo "name of female: \c "
read female
echo "water temperature in the tank: \c "
read temperature
echo "your name?: \c "
read observer

# find out whether this trial is binary or trinary
while true; do
    read -p "Binary (b) or trinary (t) trial?" bt
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

# save a log file of the trial
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
echo "standard length of female in millimeters: \c "
read length
echo "the female is $length mm long."

# email the log file to yourself for save-keeping
cat $LOG_FILE | mail -s "log file: `date`" lukereding@gmail.com
