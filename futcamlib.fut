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
import "futcamlib/oil_painting"
default (f32)

-- This shouldn't be necessary, but NumPy's reshape is stupid.
entry do_nothing [h][w] (frame: [h][w]pixel) : [h][w]pixel = frame
