include futlib.numeric
include futcamlib.base
include futcamlib.misc
include futcamlib.color
include futcamlib.selective_zoom
include futcamlib.mystery
include futcamlib.fisheye
include futcamlib.warhol
include futcamlib.whirl
include futcamlib.greyscale
include futcamlib.edgy
include futcamlib.scale
default (f32)

-- This shouldn't be necessary, but NumPy's reshape is stupid.
entry do_nothing(frame : [h][w]pixel) : [h][w]pixel = frame
