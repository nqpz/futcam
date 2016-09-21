type pixel = [3]u8 -- Well, it works.

entry scale_to(frame : [h0][w0]pixel, w1 : i32, h1 : i32) : [h1][w1]pixel =
  let y_factor = (f64 h1) / (f64 h0)
  let x_factor = (f64 w1) / (f64 w0)
  in map (fn (y1 : i32) : [w1]pixel =>
            map (fn (x1 : i32) : pixel =>
                   let y1_norm = f64 (y1 - h1 / 2)
                   let y0_norm = y1_norm / y_factor
                   let y0 = (i32 y0_norm) + h0 / 2
                   
                   let x1_norm = f64 (x1 - w1 / 2)
                   let x0_norm = x1_norm / x_factor
                   let x0 = (i32 x0_norm) + w0 / 2
                   
                   let pixel = unsafe frame[y0][x0]
                   in pixel)
         (iota w1))
  (iota h1)

entry invert_rgb(frame : [h][w]pixel) : [h][w]pixel =
  map (fn (row : [w]pixel) : [w]pixel =>
         map (fn (pixel : pixel) : pixel =>
                let r = pixel[0]
                let g = pixel[1]
                let b = pixel[2]
                in [255u8 - r, 255u8 -g, 255u8 - b])
         row)
  frame

entry dim_sides(frame : [h][w]pixel) : [h][w]pixel =
  map (fn (row : [w]pixel, y : i32) : [w]pixel =>
         map (fn (pixel : pixel, x : i32) : pixel =>
                let r = pixel[0]
                let g = pixel[1]
                let b = pixel[2]
                let x_center_closeness = 1.0f32 - f32 (abs (w / 2 - x)) / (f32 (w / 2))
                let y_center_closeness = 1.0f32 - f32 (abs (h / 2 - y)) / (f32 (h / 2))
                let center_closeness = x_center_closeness * y_center_closeness
                let strength = 1.1f32
                let center_closeness' = center_closeness ** strength
                let r' = u8 (f32 r * center_closeness')
                let g' = u8 (f32 g * center_closeness')
                let b' = u8 (f32 b * center_closeness')
                in [r', g', b'])
         (zip row (iota w)))
  (zip frame (iota h))

entry distort(frame : [h][w]pixel, distortion : f64) : [h][w]pixel =
  map (fn (y : i32) : [w]pixel =>
         map (fn (x : i32) : pixel =>
                let y_scale = ((f64 (h / 2)) ** distortion) / (f64 (h / 2))
                let x_scale = ((f64 (w / 2)) ** distortion) / (f64 (w / 2))

                let y_norm_base = f64 (y - h / 2)
                let y_lz = y_norm_base < 0.0f64
                let y_norm = if y_lz then -y_norm_base else y_norm_base
                let y' = (y_norm ** distortion) / y_scale
                let y_back = i32 (if y_lz then -y' else y') + h / 2

                let x_norm_base = f64 (x - w / 2)
                let x_lz = x_norm_base < 0.0f64
                let x_norm = if x_lz then -x_norm_base else x_norm_base
                let x' = (x_norm ** distortion) / x_scale
                let x_back = i32 (if x_lz then -x' else x') + w / 2

                let pixel = unsafe frame[y_back][x_back]
                in pixel)
         (iota w))
  (iota h)
