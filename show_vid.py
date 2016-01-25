from psychopy import visual, core, event
import pyglet, sys


# python script to run two different videos on two separate screens attached to the computer.
# run like `python show_vid.py path/video1 path/video2`


# get information about the screens. print to the screen
all_screens = pyglet.window.get_platform().get_default_display().get_screens()
print all_screens

# get sizes of all screens
for screen in all_screens:
    print screen.width, screen.height

# make sure there are two screens attached:
if len(all_screens) != 2:
    sys.exit("\n\nyou need two screens connected to the computer. exiting.\n")

#define the windows
mainWin = visual.Window([1280,800], units='norm', fullscr=False, screen=0)
secondWin = visual.Window([1920,1080], units='norm', fullscr=False, screen=1)

# load videos
mov1 = visual.MovieStim(mainWin, sys.argv[0], flipVert=False)
mov2 = visual.MovieStim(secondWin, sys.argv[1], flipVert=False)

print "the first video is %s seconds long" %{mov1.duration}
print "the second video is %s seconds long" %{mov2.duration}

print 'first video size=[%i,%i]' %(mov1.format.width, mov.format.height)
print 'second video size=[%i,%i]' %(mov2.format.width, mov.format.height)

globalClock = core.Clock()

while globalClock.getTime()<(mov.duration+60):
    mov1.draw()
    mov2.draw()
    mainWin.update()
    secondWin.update()
    
    # if a key has been pressed, exit out of the program
    if len(event.getKeys())>0: break
    event.clearEvents()

core.quit()
