#!/usr/bin/python

from psychopy import visual, core, event
import pyglet, sys, screen, argparse


'''
python script to run two different videos on two separate screens attached to the computer.
run like `python show_vid.py path/video1 path/video2`
the script will exit if you have fewer or more than two screens connected
'''

if __name__ == '__main__':
    
    # set up argument parser
    ap = argparse.ArgumentParser()
    ap.add_argument("-v1", "--video_1", help="path to the first video", required = True)
    ap.add_argument("-v2", "--video_2", help="path to the second video", required = True)
    args = vars(ap.parse_args())
    
    # get information about the screens. print to the screen
    all_screens = pyglet.window.get_platform().get_default_display().get_screens()
    print all_screens

    # define each monitor
    screen1 = screen.Screen("screen1", all_screens[0], args['video_1'], 0)
    screen2 = screen.Screen("screen2", all_screens[1], args['video_2'], 1)

    # make sure there are two screens attached:
    if len(all_screens) != 2:
        sys.exit("\n\nyou need two screens connected to the computer. exiting.\n")

    # print a bunch of stuff for the user
    print screen1.print_monitor_size()
    print screen2.print_monitor_size()
    print screen1.print_video_size()
    print screen2.print_video_size()
    print screen1.print_duration()
    print screen2.print_duration()

    # start the clock for timing
    globalClock = core.Clock()

    # start the loop to show the videos 
    while globalClock.getTime()<(screen1.duration+60):
        # draw the videos
        screen1.draw()
        screen2.draw()
        
        # if the trial is ended, let the user know:
        if globalClock.getTime() > screen1.duration+10:
            text = visual.TextStim(screen1.window, text="trial ended (!)", pos=(0,-0.6), alignVert='bottom', color='SlateGrey')
        else:
            text = visual.TextStim(screen1.window, text=str(screen1.duration - round(globalClock.getTime(),0)) + " seconds left in the video", pos=(0,-0.6), alignVert='bottom', color='SlateGrey')
        
        # draw the time, update the windows
        text.draw()
        screen1.update()
        screen2.update()
        
        # if a key has been pressed, exit out of the program
        if len(event.getKeys())>0: break
        event.clearEvents()

    core.quit()