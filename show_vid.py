from psychopy import visual, core, event
import pyglet, sys


'''
python script to run two different videos on two separate screens attached to the computer.
run like `python show_vid.py path/video1 path/video2`
the script will exit if you have fewer or more than two screens connected
'''

# get information about the screens. print to the screen
all_screens = pyglet.window.get_platform().get_default_display().get_screens()
print all_screens

# print the sizes of all screens to the user
for screen in all_screens:
    print "size of screens:\n"
    print screen.width, screen.height

# make sure there are two screens attached:
if len(all_screens) != 2:
    sys.exit("\n\nyou need two screens connected to the computer. exiting.\n")

#define the windows
mainWin = visual.Window([all_screens[0].height,all_screens[0].width], units='norm', fullscr=False, screen=0)
secondWin = visual.Window([all_screens[1].height,all_screens[1].width], units='norm', fullscr=False, screen=1)

# load videos
mov1 = visual.MovieStim(mainWin, sys.argv[1], flipVert=False)
mov2 = visual.MovieStim(secondWin, sys.argv[2], flipVert=False)

print "the first video is %s seconds long" %{mov1.duration}
print "the second video is %s seconds long" %{mov2.duration}

print 'first video size=[%i,%i]' %(mov1.format.width, mov1.format.height)
print 'second video size=[%i,%i]' %(mov2.format.width, mov2.format.height)

# start the clock for timing
globalClock = core.Clock()

while globalClock.getTime()<(mov1.duration+60):
    # draw the videos
    mov1.draw()
    mov2.draw()
    
    # if the trial is ended, let the user know:
    if globalClock.getTime() > mov1.duration+10:
        text = visual.TextStim(mainWin, text="trial ended (!)", pos=(0,-0.6), alignVert='bottom', color='SlateGrey')
    else:
        text = visual.TextStim(mainWin, text=str(round(globalClock.getTime(),0)), pos=(0,-0.6), alignVert='bottom', color='SlateGrey')
    
    # draw the time, update the windows
    text.draw()
    mainWin.update()
    secondWin.update()
    
    # if a key has been pressed, exit out of the program
    # if len(event.getKeys())>0: break
    # event.clearEvents()

core.quit()
