#!/usr/bin/env python

import sys
import argparse
import collections
import time

import pygame
import numpy
import cv2

import futcamlib


class FutCam:
    def __init__(self, resolution=None, scale_to=None):
        self.resolution = resolution
        self.scale_to = scale_to

    def run(self):
        # Open a camera device for capturing.
        self.cam = cv2.VideoCapture(0)

        if not self.cam.isOpened():
            print 'error: could not open camera.' >> sys.stderr
            return 1

        if self.resolution is not None:
            w, h = self.resolution
            self.cam.set(cv2.cv.CV_CAP_PROP_FRAME_WIDTH, w)
            self.cam.set(cv2.cv.CV_CAP_PROP_FRAME_HEIGHT, h)

        if self.scale_to is not None:
            self.width, self.height = self.scale_to
        else:
            self.width = int(self.cam.get(cv2.cv.CV_CAP_PROP_FRAME_WIDTH))
            self.height = int(self.cam.get(cv2.cv.CV_CAP_PROP_FRAME_HEIGHT))

        # Setup pygame.
        pygame.init()
        pygame.display.set_caption('futcam')
        self.screen = pygame.display.set_mode((self.width, self.height))
        self.font = pygame.font.Font(None, 36)
        self.clock = pygame.time.Clock()

        # Load the library.
        self.futhark = futcamlib.futcamlib()

        # Filters.
        self.filters = collections.OrderedDict([
            ('fisheye',
             lambda frame, user_value:
             self.futhark.fisheye(frame, max(0.1, abs(user_value * 0.05 + 1.2)))),
            ('warhol',
             lambda frame, _:
             self.futhark.warhol(frame)),
            ('whirl',
             lambda frame, user_value:
             self.futhark.whirl(frame, user_value * 0.1)),
            ('quad',
             lambda frame, _:
             self.futhark.quad(frame)),
            ('greyscale',
             lambda frame, user_value:
             self.futhark.greyscale(frame, user_value * 0.1)),
            ('invert rgb',
             lambda frame, _:
             self.futhark.invert_rgb(frame)),
            ('dim sides',
             lambda frame, user_value:
             self.futhark.dim_sides(frame, max(abs(user_value) * 0.1, 0.1))),
            ('hue focus',
             lambda frame, user_value:
             self.futhark.hue_focus(frame, user_value * 10.0)),
            # ('a mystery',
            #  lambda frame, _:
            #  self.futhark.prefixMax(frame)),
        ])

        return self.loop()

    def message(self, what, where):
        text = self.font.render(what, 1, (255, 255, 255))
        self.screen.blit(text, where)

    def loop(self):
        filter_names = self.filters.keys()
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
            retval, frame = self.cam.read()
            if not retval:
                return 1

            # Mess with the internal representation.
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2BGRA)
            frame = self.futhark.do_nothing(frame).get()

            # Scale if asked to.
            if self.scale_to is not None:
                w, h = self.scale_to
                frame = self.futhark.scale_to(frame, w, h)

            # Call Futhark filters.
            time_start = time.time()
            for f, u in zip(applied_filters, user_values[1:] + [user_value]):
                frame = self.filters[f](frame, u)
            if not type(frame) is numpy.ndarray:
                frame = frame.get()
            time_end = time.time()
            futhark_dur_ms = (time_end - time_start) * 1000

            # Mess with the internal representation.
            frame = numpy.rot90(frame)

            # Show frame.
            pygame.surfarray.blit_array(self.screen, frame)

            # Render HUD.
            if show_hud:
                for i, f in zip(range(len(applied_filters)), applied_filters):
                    self.message(f, (5, 5 + 30 * i))
                self.message(filter_names[filter_index] + '?',
                             (5, 5 + 30 * len(applied_filters)))
                self.message('FPS: {:.02f}'.format(fps),
                             (self.width - 210, 5))
                self.message('Futhark: {:.02f} ms'.format(futhark_dur_ms),
                             (self.width - 250, 35))
    
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
                        applied_filters.append(filter_names[filter_index])
                        user_values.append(user_value)
                        user_value = 0
                    elif event.key == pygame.K_BACKSPACE:
                        if len(user_values) > 0:
                            applied_filters = applied_filters[:-1]
                            user_value = user_values[-1]
                            user_values = user_values[:-1]
                    elif event.key == pygame.K_LEFT:
                        user_value_status = 1
                    elif event.key == pygame.K_RIGHT:
                        user_value_status = -1

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

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('--resolution', type=size, metavar='WIDTHxHEIGHT',
                            help='set the resolution of the webcam instead of relying on its default resolution')
    arg_parser.add_argument('--scale-to', type=size, metavar='WIDTHxHEIGHT',
                            help='scale the camera output to this size before sending it to a filter')
    args = arg_parser.parse_args(args)

    cam = FutCam(resolution=args.resolution, scale_to=args.scale_to)
    return cam.run()

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
