import "futcamlib/pixel_float"
import "futcamlib/base"
default (f32)

entry fisheye(frame : [h][w]pixel, distortion : f32) : [h][w]pixel =
  map (\(y : i32) : [w]pixel ->
         map (\(x : i32) : pixel ->
                let y_scale = ((f32 (h / 2)) ** distortion) / (f32 (h / 2))
                let x_scale = ((f32 (w / 2)) ** distortion) / (f32 (w / 2))

                let y_norm_base = f32 (y - h / 2)
                let y_lz = y_norm_base < 0.0f32
                let y_norm = if y_lz then -y_norm_base else y_norm_base
                let y' = (y_norm ** distortion) / y_scale
                let y_back = (if y_lz then -y' else y') + f32 (h / 2)

                let x_norm_base = f32 (x - w / 2)
                let x_lz = x_norm_base < 0.0f32
                let x_norm = if x_lz then -x_norm_base else x_norm_base
                let x' = (x_norm ** distortion) / x_scale
                let x_back = (if x_lz then -x' else x') + f32 (w / 2)

                let pixel = pixel_unfloat (pixel_at (frame, x_back, y_back))
                in pixel)
         (iota w))
  (iota h)
