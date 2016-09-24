#!/usr/bin/env python

import sys
import argparse
import collections

import pygame
import numpy
import cv
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
            self.cam.set(cv.CV_CAP_PROP_FRAME_WIDTH, w)
            self.cam.set(cv.CV_CAP_PROP_FRAME_HEIGHT, h)

        if self.scale_to is not None:
            width, height = self.scale_to
        else:
            width = int(self.cam.get(cv.CV_CAP_PROP_FRAME_WIDTH))
            height = int(self.cam.get(cv.CV_CAP_PROP_FRAME_HEIGHT))

        size = (width, height)

        # Setup pygame.
        pygame.init()
        pygame.display.set_caption('futcam')
        self.screen = pygame.display.set_mode(size)
        self.font = pygame.font.Font(None, 36)

        # Load the library.
        trans = futcamlib.futcamlib()

        # Filter tables.
        self.scale_methods = [
            trans.scale_to_thoughtful,
            trans.scale_to_simple
        ]

        self.filters = collections.OrderedDict([
            ('fisheye',
             lambda frame, user_value:
             trans.fisheye(frame, max(0.1, abs(user_value * 0.05 + 1.2)))),
            ('warhol',
             lambda frame, _:
             trans.warhol(frame)),
            ('whirl',
             lambda frame, user_value:
             trans.whirl(frame, user_value * 0.1)),
            ('quad',
             lambda frame, _:
             trans.quad(frame)),
            ('greyscale',
             lambda frame, user_value:
             trans.greyscale(frame, user_value * 0.1)),
            ('invert_rgb',
             lambda frame, _:
             trans.invert_rgb(frame)),
            ('dim_sides',
             lambda frame, user_value:
             trans.dim_sides(frame, max(abs(user_value) * 0.1, 0.1))),
            # ('a mystery',
            #  lambda frame, _:
            #  trans.prefixMax(frame)),
        ])

        return self.loop()

    def message(self, what, where):
        text = self.font.render(what, 1, (255, 255, 255))
        self.screen.blit(text, where)

    def loop(self):
        filter_names = self.filters.keys()

        scale_index = 0
        filter_index = 0

        applied_filters = []

        user_value = 0
        while True:
            # Read frame.
            retval, frame = self.cam.read()
            if not retval:
                return 1

            # Mess with the internal representation.
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2BGRA)

            # Scale if asked to.
            if self.scale_to is not None:
                w, h = self.scale_to
                frame = self.scale_methods[scale_index](frame, w, h)

            # Call Futhark filter.
            for f in applied_filters:
                frame = self.filters[f](frame, user_value)
            if not type(frame) is numpy.ndarray:
                frame = frame.get()

            # Mess with the internal representation.
            frame = numpy.rot90(frame)

            # Show frame.
            pygame.surfarray.blit_array(self.screen, frame)

            # Render HUD.
            for i, f in zip(range(len(applied_filters)), applied_filters):
                self.message(f, (0, 30 * i))
            self.message(filter_names[filter_index] + '?',
                         (0, 30 * len(applied_filters)))

            # Show on screen.
            pygame.display.flip()

            # Check events.
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return 0
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_q:
                        return 0

                    elif event.key == pygame.K_s:
                        scale_index = (scale_index + 1) % len(scale_methods)

                    elif event.key == pygame.K_UP:
                        filter_index = (filter_index + 1) % len(self.filters)
                    elif event.key == pygame.K_DOWN:
                        filter_index = (filter_index - 1) % len(self.filters)

                    elif event.key == pygame.K_RETURN:
                        applied_filters.append(filter_names[filter_index])
                    elif event.key == pygame.K_BACKSPACE:
                        applied_filters = applied_filters[:-1]

                    elif event.key == pygame.K_LEFT:
                        user_value -= 1
                    elif event.key == pygame.K_RIGHT:
                        user_value += 1

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
