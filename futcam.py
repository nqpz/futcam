#!/usr/bin/env python

import sys
import argparse

import pygame
import numpy
import cv
import cv2

import futcam_transforms


class FutCam:
    def __init__(self, resolution=None, scale_to=None):
        self.resolution = resolution
        self.scale_to = scale_to

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
        screen = pygame.display.set_mode(size)
        surface = pygame.Surface(size)

        # Setup the transforms.
        trans = futcam_transforms.futcam_transforms()

        distortion = 1.3
        while True:
            # Read frame.
            retval, frame = cam.read()
            if not retval:
                return 1

            # Mess with the internal representation.
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            if self.scale_to is not None:
                w, h = self.scale_to
                frame = trans.scale_to(frame, w, h)

            # Call Futhark function.
            #frame = trans.invert_rgb(frame)
            #frame = trans.dim_sides(frame)
            frame = trans.distort(frame, distortion)
            frame = frame.get()

            # Mess with the internal representation.
            frame = numpy.rot90(frame)

            # Show frame.
            pygame.surfarray.blit_array(surface, frame)
            screen.blit(surface, (0, 0))
            pygame.display.flip()

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    return 0
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_DOWN:
                        distortion -= 0.05
                    if event.key == pygame.K_UP:
                        distortion += 0.05


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
