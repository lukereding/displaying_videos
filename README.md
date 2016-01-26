# displaying_videos

This repo contains ideas for code and beginnings of implementing it to play three different videos on three different screens on two different computers. It currently uses [psychopy](http://www.psychopy.org/) to do this.

Trials are run with the `run_IIA.sh` command, which logs the trial, randomizes which video gets sent where, and emails the results to me. The actual showing of the videos is done with `show_vid.py` which is called by the above shell script.

See the `basics_for_IIA.md` markdown file for more info.
