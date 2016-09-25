include futcamlib.mystery
include futcamlib.fisheye
include futcamlib.warhol
include futcamlib.whirl
include futcamlib.greyscale
include futcamlib.misc
include futcamlib.scale
include futcamlib.base
default (f32)

-- This shouldn't be necessary, but NumPy's reshape is stupid.
entry do_nothing(frame : [h][w]pixel) : [h][w]pixel = frame
