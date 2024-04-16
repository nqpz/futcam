#!/usr/bin/env python3

import sys
import os.path
import argparse
import collections
import time
import tempfile
import subprocess
import threading
import importlib

import pygame
import numpy
import cv2

import futcamlib

class Spawner(threading.Thread):
    pass

def spawn(f, *args):
    s = Spawner(target=f, args=args)
    s.start()
    return s

class FutCam:
    def __init__(self, resolution=None, scale_to=None):
        self.resolution = resolution
        self.scale_to = scale_to

    def run(self):
        # Open a camera device for capturing.
        self.cam = cv2.VideoCapture(0)

        if not self.cam.isOpened():
            print('error: could not open camera.', file=sys.stderr)
            return 1

        if self.resolution is not None:
            w, h = self.resolution
            self.cam.set(cv2.CAP_PROP_FRAME_WIDTH, w)
            self.cam.set(cv2.CAP_PROP_FRAME_HEIGHT, h)

        if self.scale_to is not None:
            self.width, self.height = self.scale_to
        else:
            self.width = int(self.cam.get(cv2.CAP_PROP_FRAME_WIDTH))
            self.height = int(self.cam.get(cv2.CAP_PROP_FRAME_HEIGHT))

        # Load the library.
        self.futhark = futcamlib.futcamlib(interactive=True)

        # Setup pygame.
        pygame.init()
        pygame.display.set_caption('futcam')
        self.screen = pygame.display.set_mode((self.width, self.height))
        self.surface = pygame.Surface((self.width, self.height), depth=32)
        self.font = pygame.font.Font(None, 36)
        self.clock = pygame.time.Clock()

        # Filters.
        # FIXME: The commented-out filters have stopped working.
        self.filters = collections.OrderedDict([
            ('nothing',
             ('do_nothing', 0,
              lambda _: [])),
            ('fisheye',
             ('fisheye', 1,
              lambda user_value: [max(0.1, abs(user_value * 0.05 + 1.2))])),
            ('selective zoom',
             ('selective_zoom', 1,
              lambda user_value: [float(user_value)])),
            ('colored boxes',
             ('colored_boxes', 1,
              lambda user_value: [max(1, user_value)])),
            ('warhol',
             ('warhol', 0,
              lambda _: [])),
            ('whirl',
             ('whirl', 1,
              lambda user_value: [user_value * 0.1])),
            ('quad',
             ('quad', 0,
              lambda _: [])),
            # ('edgy',
            #  ('edgy', 1,
            #   lambda user_value: [max(1, user_value + 1)])),
            ('greyscale',
             ('greyscale', 1,
              lambda user_value: [user_value * 0.1])),
            ('invert rgb',
             ('invert_rgb', 0,
              lambda _: [])),
            ('balance white',
             ('balance_white', 1,
              lambda user_value: [user_value * 0.1])),
            ('balance saturation',
             ('balance_saturation', 1,
              lambda user_value: [user_value * 0.1])),
            ('dim sides',
             ('dim_sides', 1,
              lambda user_value: [max(abs(user_value) * 0.1, 0.1)])),
            ('hue focus',
             ('hue_focus', 1,
              lambda user_value: [user_value * 10.0])),
            ('value focus',
             ('value_focus', 1,
              lambda user_value: [user_value * 0.1])),
            ('saturation focus',
             ('saturation_focus', 1,
              lambda user_value: [user_value * 0.1])),
            ('merge colors',
             ('merge_colors', 1,
              lambda user_value: [1.0 + user_value * 5.0])),
            ('equalise saturation',
             ('equalise_saturation', 0,
              lambda _: [])),
            ('median filter',
             ('median_filter', 1,
              lambda user_value: [int(user_value)])),
            # ('a mystery',
            #  ('mystery', 0,
            #   lambda _: [])),
            ('simple blur',
             ('simple_blur', 1,
              lambda user_value: [int(user_value)])),
            ('fake heatmap',
             ('fake_heatmap', 0,
              lambda _: [])),
            ('blur low color',
             ('blur_low_color', 1,
              lambda user_value: [min(1.0, max(0.01, user_value * 0.1))])),
            ('oil painting',
             ('oil_painting', 1,
              lambda user_value: [int(user_value)])),
            # ('highpass',
            #  ('highpass', 1,
            #   lambda user_value: [int(user_value)])),
        ])

        return self.loop()

    def message(self, what, where):
        text = self.font.render(what, 1, (255, 255, 255))
        self.screen.blit(text, where)

    def loop(self):
        filter_names = list(self.filters.keys())
        filter_index = 0

        applied_filters = []

        show_hud = True

        user_value = 0
        user_value_status = 0
        user_values = []
        user_value_change_speed = 13

        while True:
            fps = self.clock.get_fps()

            # Read frame.
            time_start = time.time()
            retval, frame = self.cam.read()
            if not retval:
                return 1
            time_end = time.time()
            cam_read_dur_ms = (time_end - time_start) * 1000

            # Mess with the internal representation.
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2BGRA).view('int32')
            frame = self.futhark.do_nothing(frame).get()

            # Scale if asked to.
            if self.scale_to is not None:
                w, h = self.scale_to
                frame = self.futhark.scale_to(frame, w, h)

            time_start = time.time()

            render_method = 'Interpret'
            for i, u in zip(applied_filters + [filter_index],
                            user_values + [user_value]):
                func_name, _func_args_num, func_args_func = self.filters[filter_names[i]]
                func_args = func_args_func(u)
                frame = eval('self.futhark.{}'.format(func_name))(frame, *func_args)
            frame = frame.get()

            time_end = time.time()
            futhark_dur_ms = (time_end - time_start) * 1000

            # Mess with the internal representation.
            frame = numpy.transpose(frame)

            # Show frame.
            pygame.surfarray.blit_array(self.surface, frame)
            self.screen.blit(self.surface, (0, 0))

            # Render HUD.
            if show_hud:
                for i, fi, u in zip(range(len(applied_filters)), applied_filters, user_values):
                    self.message('{} {:.2f}'.format(filter_names[fi], u), (5, 5 + 30 * i))
                self.message('{} {:.2f}?'.format(filter_names[filter_index], user_value),
                             (5, 5 + 30 * len(applied_filters)))
                self.message('Camera read: {:.2f} ms'.format(cam_read_dur_ms),
                             (self.width - 310, 5))
                self.message('Futhark: {:.2f} ms'.format(futhark_dur_ms),
                             (self.width - 250, 35))
                self.message('FPS: {:.2f}'.format(fps),
                             (self.width - 210, 65))
                self.message('Stack: {}'.format(render_method),
                             (self.width - 210, 95))

            # Show on screen.
            pygame.display.flip()

            # Check events.
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return 0

                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_q:
                        return 0

                    elif event.key == pygame.K_UP:
                        filter_index = (filter_index - 1) % len(self.filters)
                    elif event.key == pygame.K_DOWN:
                        filter_index = (filter_index + 1) % len(self.filters)

                    elif event.key == pygame.K_RETURN:
                        applied_filters.append(filter_index)
                        user_values.append(user_value)
                        user_value = 0
                    elif event.key == pygame.K_BACKSPACE:
                        if len(user_values) > 0:
                            filter_index = applied_filters[-1]
                            applied_filters = applied_filters[:-1]
                            user_value = user_values[-1]
                            user_values = user_values[:-1]
                    elif event.key == pygame.K_LEFT:
                        user_value_status = -1
                    elif event.key == pygame.K_RIGHT:
                        user_value_status = 1

                    elif event.key == pygame.K_h:
                        show_hud = not show_hud

                elif event.type == pygame.KEYUP:
                    if event.key == pygame.K_LEFT:
                        user_value_status = 0
                    elif event.key == pygame.K_RIGHT:
                        user_value_status = 0

            if user_value_status != 0:
                user_value += user_value_status * (user_value_change_speed / fps)

            self.clock.tick()

def main(args):
    def size(s):
        return tuple(map(int, s.split('x')))

    description='''
Use up and down arrow keys to navigate the filters.  Use left and right arrow
keys to adjust a special variable sent to some of the filters.  Press Enter to
activate a filter.  Press backspace to deactivate it.  Press `h` to toggle the
HUD.  Press `q` to exit.
'''
    arg_parser = argparse.ArgumentParser(description=description)
    arg_parser.add_argument('--resolution', type=size, metavar='WIDTHxHEIGHT',
                            help='set the resolution of the webcam instead of relying on its default resolution')
    arg_parser.add_argument('--scale-to', type=size, metavar='WIDTHxHEIGHT',
                            help='scale the camera output to this size before sending it to a filter')
    args = arg_parser.parse_args(args)

    cam = FutCam(resolution=args.resolution, scale_to=args.scale_to)
    return cam.run()

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
