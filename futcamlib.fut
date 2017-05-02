import "futcamlib/base"
import "futcamlib/color"
import "futcamlib/selective_zoom"
import "futcamlib/mystery"
import "futcamlib/fisheye"
import "futcamlib/warhol"
import "futcamlib/whirl"
import "futcamlib/greyscale"
import "futcamlib/edgy"
import "futcamlib/scale"
default (f32)

-- This shouldn't be necessary, but NumPy's reshape is stupid.
entry do_nothing(frame : [#h][#w]pixel) : [h][w]pixel = frame
