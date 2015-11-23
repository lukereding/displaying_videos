import pyglet

"""
to do:
-- function for to get the size of the video file, probably through a subprocess call to ffmpeg
"""

# video name
name = '/Users/lukereding/Desktop/small_vs_intermediate_2.mp4'

platform = pyglet.window.get_platform()
display = platform.get_default_display()
screens = display.get_screens()

if len(screens) == 2:
    print "two displays connected"

# supply width and height of video
window = pyglet.window.Window(1280,1024, str(screens[1]))
#window_1 = pyglet.window.Window(1280,1024, screens[1])

video = pyglet.media.Player() # create a video player
media = pyglet.media.load(name) # supply the media file

video.queue(media) # add the media file to the queue
video.play()       # begin to play file on the queue

@window.event
def on_draw():
    # now rendering the media file
    video.get_texture().blit(0, 0)

pyglet.app.run() # run the program
