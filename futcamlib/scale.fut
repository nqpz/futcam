include futcamlib.pixel_float
include futcamlib.base
default (f32)

entry scale_to(frame : [h0][w0]pixel, w1 : i32, h1 : i32) : [h1][w1]pixel =
  let y_factor = (f32 h1) / (f32 h0)
  let x_factor = (f32 w1) / (f32 w0)
  in map (\(y1 : i32) : [w1]pixel ->
            map (\(x1 : i32) : pixel ->
                   let y1_norm = f32 (y1 - h1 / 2)
                   let y0_norm = y1_norm / y_factor
                   let y0 = y0_norm + f32 (h0 / 2)

                   let x1_norm = f32 (x1 - w1 / 2)
                   let x0_norm = x1_norm / x_factor
                   let x0 = x0_norm + f32 (w0 / 2)

                   let xy_val = pixel_at (frame, x0, y0)

                   let pixel = pixel_unfloat xy_val
                   in pixel)
         (iota w1))
  (iota h1)
