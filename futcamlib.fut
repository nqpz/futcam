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

entry scale_to [h0][w0] (frame: [h0][w0]pixel) (w1: i32) (h1: i32): [h1][w1]pixel =
  effects.scale_to frame w1 h1

entry blur_low_color [h][w] (frame: [h][w]pixel) (threshold: f32): [h][w]pixel =
  effects.blur_low_color frame threshold

entry fake_heatmap [h][w] (frame: [h][w]pixel): [h][w]pixel =
  effects.fake_heatmap frame

entry simple_blur [h][w] (frame: [h][w]pixel) (iterations: i32): [h][w]pixel =
  effects.simple_blur frame iterations

entry median_filter [h][w] (frame: [h][w]pixel) (iterations: i32): [h][w]pixel =
  effects.median_filter frame iterations

entry equalise_saturation [h][w] (frame: [h][w]pixel): [h][w]pixel =
  effects.equalise_saturation frame

entry merge_colors [h][w] (frame: [h][w]pixel) (group_size: f32): [h][w]pixel =
  effects.merge_colors frame group_size

entry saturation_focus [h][w] (frame: [h][w]pixel) (value_focus: f32): [h][w]pixel =
  effects.saturation_focus frame value_focus

entry value_focus [h][w] (frame: [h][w]pixel) (value_focus: f32): [h][w]pixel =
  effects.value_focus frame value_focus

entry hue_focus [h][w] (frame: [h][w]pixel) (hue_focus: f32): [h][w]pixel =
  effects.hue_focus frame hue_focus

entry dim_sides [h][w] (frame: [h][w]pixel) (strength: f32): [h][w]pixel =
  effects.dim_sides frame strength

entry balance_saturation [h][w] (frame: [h][w]pixel) (sat_target: f32): [h][w]pixel =
  effects.balance_saturation frame sat_target

entry balance_white [h][w] (frame: [h][w]pixel) (value_target: f32): [h][w]pixel =
  effects.balance_white frame value_target

entry invert_rgb [h][w] (frame: [h][w]pixel): [h][w]pixel =
  effects.invert_rgb frame

entry quad [h][w] (frame: [h][w]pixel): [h][w]pixel =
  effects.quad frame

entry colored_boxes [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  effects.colored_boxes frame distortion

entry selective_zoom [h][w] (frame: *[h][w]pixel) (threshold: f32): [h][w]pixel =
  effects.selective_zoom frame threshold

entry mystery [h][w] (frame: [h][w]pixel): [h][w]pixel =
  effects.mystery frame

entry fisheye [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  effects.fisheye frame distortion

entry warhol [h][w] (frame: [h][w]pixel): [h][w]pixel =
  effects.warhol frame

entry whirl [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  effects.whirl frame distortion

entry greyscale [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  effects.greyscale frame distortion

entry edgy [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  effects.edgy frame distortion

entry oil_painting [h][w] (frame: [h][w]pixel) (breadth: i32): [h][w]pixel =
  effects.oil_painting frame breadth

entry highpass [h][w] (frame: [h][w]pixel) (cutoff: i32): [h][w]pixel =
  effects.highpass frame cutoff
