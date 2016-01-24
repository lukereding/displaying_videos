from psychopy import visual, core, event
import pyglet

all_screens = pyglet.window.get_platform().get_default_display().get_screens()
print all_screens

# get sizes of all screens
for screen in all_screens:
    print screen.width, screen.height


mainWin = visual.Window([1280,800], units='norm', fullscr=False, screen=0)

text = visual.TextStim(mainWin, text='Hello nerds',pos=(0,0))

mov = visual.MovieStim(mainWin, 'smallMale2.avi', flipVert=False)

if len(all_screens) == 2:
    secondWin = visual.Window([1920,1080], units='norm', fullscr=False, screen=1)
    mov2 = visual.MovieStim(secondWin, 'out.avi', flipVert=False)

print "the video is %s seconds long" %{mov.duration}

print 'video size=[%i,%i]' %(mov.format.width, mov.format.height)
globalClock = core.Clock()

while globalClock.getTime()<(mov.duration+0.5):
    mov.draw()
    text.draw()
    mainWin.update()
    if secondWin:
        mov2.draw()
        text.draw()
        secondWin.update()


    # if a key has been pressed, exit out of the program
    if len(event.getKeys())>0: break
    event.clearEvents()

core.quit()
