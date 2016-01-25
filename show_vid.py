#!/usr/bin/python

from psychopy import visual, core, event
import pyglet, sys


'''
python script to run two different videos on two separate screens attached to the computer.
run like `python show_vid.py path/video1 path/video2`
the script will exit if you have fewer or more than two screens connected
'''

class Screen:
    
    '''
    screen class! 
    example: Screen("screen1", all_screens[0], "/Users/lukereding/Documents/blender_files/transitivity/size/small_vs_large2.mp4")
    '''
    
    def __init__(self, name, monitor, video_path, number):
        self.name = name
        self.width = monitor.width
        self.height = monitor.height
        self.window = visual.Window([monitor.width, monitor.height], units='norm', fullscr=False, screen=number)
        self.video =  visual.MovieStim(self.window, video_path, flipVert=False)
        self.video_width = int(self.video.format.width)
        self.video_height = int(self.video.format.height)
        self.video_path = video_path
        self.duration = self.video.duration
        
    def print_monitor_size(self):
        print "monitor {} has height of {} and width of {}.".format(self.name, self.width, self.height)
    
    def print_video_size(self):
        print "{} is {} x {}".format(self.video_path, self.video_height, self.video_width)
    
    def print_duration(self):
        "{} is {} s long".format(self.video, self.duration)
    
    def draw(self):
        self.video.draw()
    
    def update(self):
        self.window.update()



# get information about the screens. print to the screen
all_screens = pyglet.window.get_platform().get_default_display().get_screens()
print all_screens

# define each monitor
screen1 = Screen("screen1", all_screens[0], str(sys.argv[1]), 0)
screen2 = Screen("screen2", all_screens[1], str(sys.argv[2]), 1)

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

while globalClock.getTime()<(screen1.duration+60):
    # draw the videos
    screen1.draw()
    screen2.draw()
    
    # if the trial is ended, let the user know:
    if globalClock.getTime() > screen1.duration+10:
        text = visual.TextStim(screen1.window, text="trial ended (!)", pos=(0,-0.6), alignVert='bottom', color='SlateGrey')
    else:
        text = visual.TextStim(screen1.window, text=str(round(globalClock.getTime(),0)), pos=(0,-0.6), alignVert='bottom', color='SlateGrey')
    
    # draw the time, update the windows
    text.draw()
    screen1.update()
    screen2.update()
    
    # if a key has been pressed, exit out of the program
    if len(event.getKeys())>0: break
    event.clearEvents()

core.quit()
