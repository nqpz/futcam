import "futcamlib/base"

-- This shouldn't be necessary, but NumPy's reshape is stupid.
entry do_nothing [h][w] (frame: [h][w]pixel) : [h][w]pixel = frame

module effects = {
  open import "futcamlib/misc"
  open import "futcamlib/scale"

  open import "futcamlib/selective_zoom"
  open import "futcamlib/mystery"
  open import "futcamlib/fisheye"
  open import "futcamlib/warhol"
  open import "futcamlib/whirl"
  open import "futcamlib/greyscale"
  open import "futcamlib/edgy"
  open import "futcamlib/oil_painting"
  open import "futcamlib/highpass"
}

entry scale_to = effects.scale_to

entry blur_low_color = effects.blur_low_color

entry fake_heatmap = effects.fake_heatmap

entry simple_blur = effects.simple_blur

entry median_filter = effects.median_filter

entry equalise_saturation = effects.equalise_saturation

entry merge_colors = effects.merge_colors

entry saturation_focus = effects.saturation_focus

entry value_focus = effects.value_focus

entry hue_focus = effects.hue_focus

entry dim_sides = effects.dim_sides

entry balance_saturation = effects.balance_saturation

entry balance_white = effects.balance_white

entry invert_rgb = effects.invert_rgb

entry quad = effects.quad

entry colored_boxes = effects.colored_boxes

entry selective_zoom = effects.selective_zoom

entry mystery = effects.mystery

entry fisheye = effects.fisheye

entry warhol = effects.warhol

entry whirl = effects.whirl

entry greyscale = effects.greyscale

entry edgy = effects.edgy

entry oil_painting = effects.oil_painting

entry highpass = effects.highpass
