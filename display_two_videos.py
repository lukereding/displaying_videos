import pyglet, sys
from time import sleep

"""
to do:
-- function for to get the size of the video file, probably through a subprocess call to ffmpeg
-- function to get the size of each screen (display?)
"""

# read video names
name1 = sys.argv[0]
name2 = sys.argv[1]

platform = pyglet.window.get_platform()
display = platform.get_default_display()
screens = display.get_screens()
print screens

if len(screens) == 2:
    print "two displays connected"
    if not name2:
        sys.exit("\n\nmissing argument for second video. exiting.\n")
else:
    sys.exit("\n\nyou need at least two screens connected to the computer. exiting.\n")

# supply width and height of video
window = pyglet.window.Window(screens[1].width,screens[1].height, screen = screens[0], visible = False, fullscreen = True)
window.set_location(screens[1].x, screens[1].y)
window.set_visible()

window_1 = pyglet.window.Window(screens[0].width,screens[0].height, screen = screens[0], visible = False, fullscreen = True)
window_1.set_location(screens[0].x, screens[0].y)
window_1.set_visible()

video = pyglet.media.Player() # create a video player
media = pyglet.media.load(name) # supply the media file

video.queue(media) # add the media file to the queue
video.play()       # begin to play file on the queue

@window.event
def on_draw():
    # now rendering the media file
    video.get_texture().blit(0, 0)

@window_1.event
def on_draw():
    # now rendering the media file
    video.get_texture().blit(0, 0)

pyglet.app.run() # run the program
