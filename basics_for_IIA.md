## things the program need to do:


some tasks I need to code:
(1) have the user enter in basic information to be logged
(2) randomly choose two - three videos
(3) send a script over ssh to a third computer that will run one of the videos
(4) log everything


(1) have the user enter basic information
> \#!/usr/bin/env bash

`echo -e "Name of female: \c " `      
`read word`     
`echo "today's date: \c "`       
`read date`

while true; do
    read -p "Binary (b) or trinary (t) trial?" bt
    case $bt in
        [Bb]* ) echo "binary trial "; trial_type=binary; break;;
        [Tt]* ) echo "trinary trial"; trial_type=trinary; break;;
        * ) echo "Please answer b or t.";;
    esac
done

TO DO
- check to see if the file exits
- append if so
- save a backup regardless

echo "$word, $date" > results

(2) randomly choose two - three variables

*if trinary trial then do:*

array=( $(echo "small;large;decoy" | sed 's,([^;]\(*\)[;$]),\1,g' | tr ";" "\n" | gshuf | tr "\n" " " ) )
echo ${array[0]}
echo ${array[1]}
echo ${array[2]}

*if binary trial then do:*
array=( $(echo "small;large" | sed 's,([^;]\(*\)[;$]),\1,g' | tr ";" "\n" | gshuf | tr "\n" " " ) )
echo ${array[0]}
echo ${array[1]}
**

- send to python script
python script.py --video1 ${array[0]} --video2 ${array[1]}


(3) send a script over ssh to a third computer that will run one of the videos

- if trinary trial, then do:

ssh $MINI1 'python script.py ${array[2]}'

(4) log everything
