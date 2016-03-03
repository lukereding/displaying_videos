import pyglet, sys
from psychopy import visual, core, event

class Screen:
    
    '''
    screen class! 
    use it to define your screen and what video it will play
    example: Screen("screen1", all_screens[0], /Users/lukereding/Documents/blender_files/transitivity/size/small_vs_large2.mp4, 0)
    '''
    
    def __init__(self, name, monitor, video_path, number):
        self.name = name
        self.width = monitor.width
        self.height = monitor.height
        self.window = visual.Window([monitor.width, monitor.height], units='norm', fullscr=False, screen=number, allowGUI=False)
        self.video =  visual.MovieStim(self.window, video_path, flipVert=False)
        self.video_width = int(self.video.format.width)
        self.video_height = int(self.video.format.height)
        self.video_path = video_path
        self.duration = self.video.duration
        
    def print_monitor_size(self):
        return "{} has height of {} and width of {}.".format(self.name, self.width, self.height)
    
    def print_video_size(self):
        return "the video {} is {} x {}".format(self.video_path, self.video_height, self.video_width)
    
    def print_duration(self):
        return "{} is {} s long".format(self.video_path, self.duration)
    
    def draw(self):
        self.video.draw()
    
    def update(self):
        self.window.update()


def cleanup():
    '''
    cleanup function to be called if a KeyboardInterrupt is raised
    '''
    print "control C was pressed. aborting script and cleaning up monitors."
    core.quit()
    sys.exit(10)