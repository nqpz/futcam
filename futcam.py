#!/usr/bin/env python

import sys

import pygame
import numpy
import cv2

import futcam_transforms


def main(args):
    # Open a camera device for capturing.
    cam = cv2.VideoCapture(0);

    if not cam.isOpened():
        print 'error: could not open camera.' >> sys.stderr
        return 1

    # Setup pygame.
    pygame.init()
    pygame.display.set_caption('futcam')
    size = (640, 480) # TODO: Get fram cam.
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

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
