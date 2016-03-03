#!/usr/bin/python

from time import time
from psychopy import visual, core, event
import pyglet, sys, screen, argparse, os.path

'''
python script to run two different videos on two separate screens attached to the computer.
run like `python show_vid.py -v1 path/video1 path/video2`

the second video argument is actually optional; if omitted, it'll just show one video on whatever your main monitor is
example: `python show_vid.py -v1 /Users/lukereding/Documents/blender_files/transitivity/s
ize/small_vs_large1.mp4`

the -t or --time argument is important for tiing when trying to synch video playback between two computers. the script will be executed when the seconds since epoch gets to the seconds given by --time
'''

if __name__ == '__main__':

    # get information about the monitors hooked up to the computer
    all_screens = pyglet.window.get_platform().get_default_display().get_screens()

    # set up argument parser
    ap = argparse.ArgumentParser()
    ap.add_argument("-v1", "--video_1", help="path to the first video", required = True)
    ap.add_argument("-v2", "--video_2", help="path to the second video", required = False)
    ap.add_argument("-t", "--time", help="current time in seconds since epoch", required = False, type=int, default = time())

    args = vars(ap.parse_args())
    start_time = args['time']

    if args['video_2'] is None:
        print "\n\nyou've only entered one video name. Will only show one video.\n\n"
        screen2 = False
        if not os.path.isfile(args['video_1']):
            print "\n\nlooks like the video path doesn't point to a valid file. exiting.\n\n"
            sys.exit(1)
    else:
        screen2 = True
        # make sure the videos exists
        if not os.path.isfile(args['video_1']):
            print "\n\nvideo 1 doesn't exist. make sure you enter the path to the videos correctly. exiting the script.\n\n"
            sys.exit(3)
        if not os.path.isfile(args['video_2']):
            print "\n\n\nvideo 2 doesn't exist. make sure you enter the path to the videos correctly. exiting the script.\n\n"
            sys.exit(3)
        # check to make sure two monitors are attached to the computer
        if len(all_screens) != 2:
            print "\n\n\nyou've entered two videos, but your computer is only connected to one monitor.\nTry adding another monitor."
            sys.exit(2)

    #set up screen1 regardless
    screen1 = screen.Screen("screen1", all_screens[0], args['video_1'], 0)
    print screen1.print_monitor_size()
    print screen1.print_video_size()
    print screen1.print_duration()

    # if there's a second screen, set it up:
    try:
        # if you have a second screen to play with:
        if screen2:
            screen2 = screen.Screen("screen2", all_screens[1], args['video_2'], 1)
            print "\n\n" + screen2.print_monitor_size()
            print screen2.print_video_size()
            print screen2.print_duration()
    except:
        print "\nonly using one screen\n"

    # let the user know how to quit
    print "\n\npress Control + C on the keyboard to kill the videos and recording and end the trial.\nnote that this will void the trial. exercise caution!"

    screen1.draw()
    if screen2:
        screen2.draw()

    # if you uncomment this, no weird intro period to the video, but you lose the first 10 seconds of the video
    #core.wait(10)

    # wait until 15 seconds after the script has started. This ensures that two computers start playing the videos at the same time.
    while(int(time()) < start_time):
        pass

    # start the clock for timing
    globalClock = core.Clock()

    # start the loop to show the videos
    while globalClock.getTime() < (screen1.duration):

        try:
            # draw the videos
            screen1.draw()
            if screen2:
                screen2.draw()

            # to draw text:
            #text = visual.TextStim(screen1.window, text=str(screen1.duration - round(globalClock.getTime(),0)) + " seconds left in the video", pos=(0,-0.6), alignVert='bottom', color='SlateGrey')

            # update the windows
            #text.draw()
            screen1.update()
            if screen2:
                screen2.update()

            # if a key has been pressed, exit out of the program
            if len(event.getKeys(keyList="q"))>0:
                event.clearEvents()
                core.quit()
                sys.exit(5)

        except KeyboardInterrupt:
            screen.cleanup()

    core.quit()
core.quit()
sys.exit()
