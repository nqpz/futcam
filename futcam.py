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

    def message(self, what, where):
        text = self.font.render(what, 1, (255, 255, 255))
        self.screen.blit(text, where)

    def run(self):
        # Open a camera device for capturing.
        cam = cv2.VideoCapture(0)

        if not cam.isOpened():
            print 'error: could not open camera.' >> sys.stderr
            return 1

        if self.resolution is not None:
            w, h = self.resolution
            cam.set(cv.CV_CAP_PROP_FRAME_WIDTH, w)
            cam.set(cv.CV_CAP_PROP_FRAME_HEIGHT, h)

        if self.scale_to is not None:
            width, height = self.scale_to
        else:
            width = int(cam.get(cv.CV_CAP_PROP_FRAME_WIDTH))
            height = int(cam.get(cv.CV_CAP_PROP_FRAME_HEIGHT))

        size = (width, height)

        # Setup pygame.
        pygame.init()
        pygame.display.set_caption('futcam')
        self.screen = screen = pygame.display.set_mode(size)
        self.font = pygame.font.Font(None, 36)

        # Setup the transforms.
        trans = futcamlib.futcamlib()

        scale_methods = [
            trans.scale_to_thoughtful,
            trans.scale_to_simple
        ]
        scale_index = 0

        distortion = 0
        distort_methods = collections.OrderedDict([
            ('invert_rgb',
             lambda frame, _:
             trans.invert_rgb(frame)),
            ('dim_sides',
             lambda frame, user_value:
             trans.dim_sides(frame, (abs(user_value) + 1) ** 0.7)),
            ('fisheye',
             lambda frame, user_value:
             trans.fisheye(frame, max(0.1, abs(user_value * 0.05 + 1)))),
            ('greyscale',
             lambda frame, user_value:
             trans.greyscale(frame, user_value * 0.1)),
            ('warhol',
             lambda frame, _:
             trans.warhol(frame)),
            ('quad',
             lambda frame, _:
             trans.quad(frame)),
            ('whirl',
             lambda frame, user_value:
             trans.whirl(frame, user_value * 0.1)),
            # ('a mystery',
            #  lambda frame, _:
            #  trans.prefixMax(frame)),
        ])
        distorts = []
        distort_names = distort_methods.keys()
        distort_index = 0
        user_value = 0
        while True:
            # Read frame.
            retval, frame = cam.read()
            if not retval:
                return 1

            # Mess with the internal representation.
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2BGRA)

            if self.scale_to is not None:
                w, h = self.scale_to
                frame = scale_methods[scale_index](frame, w, h)

            # Call Futhark function.
            for d in distorts:
                frame = distort_methods[d](frame, user_value)
            if not type(frame) is numpy.ndarray:
                frame = frame.get()

            # Mess with the internal representation.
            frame = numpy.rot90(frame)

            # Show frame.
            pygame.surfarray.blit_array(screen, frame)

            for (i,d) in zip(range(len(distorts)), distorts):
                self.message(d, (0,30*i))
            self.message(distort_names[distort_index] + '?', (0,30*len(distorts)))

            pygame.display.flip()

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return 0
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_q:
                        return 0
                    if event.key == pygame.K_DOWN:
                        user_value -= 1
                    if event.key == pygame.K_UP:
                        user_value += 1
                    if event.key == pygame.K_s:
                        scale_index = (scale_index + 1) % len(scale_methods)
                    if event.key == pygame.K_d:
                        distort_index = (distort_index + 1) % len(distort_methods)
                    if event.key == pygame.K_RETURN:
                        distorts += [distort_names[distort_index]]
                    if event.key == pygame.K_BACKSPACE:
                        distorts = distorts[:-1]

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
