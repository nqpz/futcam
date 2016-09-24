include futcamlib.base
default (f32)

entry fisheye(frame : [h][w]pixel, distortion : f32) : [h][w]pixel =
  map (fn (y : i32) : [w]pixel =>
         map (fn (x : i32) : pixel =>
                let y_scale = ((f32 (h / 2)) ** distortion) / (f32 (h / 2))
                let x_scale = ((f32 (w / 2)) ** distortion) / (f32 (w / 2))

                let y_norm_base = f32 (y - h / 2)
                let y_lz = y_norm_base < 0.0f32
                let y_norm = if y_lz then -y_norm_base else y_norm_base
                let y' = (y_norm ** distortion) / y_scale
                let y_back = i32 (if y_lz then -y' else y') + h / 2

                let x_norm_base = f32 (x - w / 2)
                let x_lz = x_norm_base < 0.0f32
                let x_norm = if x_lz then -x_norm_base else x_norm_base
                let x' = (x_norm ** distortion) / x_scale
                let x_back = i32 (if x_lz then -x' else x') + w / 2

                let pixel = unsafe frame[y_back][x_back]
                in pixel)
         (iota w))
  (iota h)
