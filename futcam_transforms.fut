include futcam_base
include futcam_scale

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

fun intensity (c: pixel): int = int c[0] + int c[1] + int c[2]

fun min (x: int) (y: int): int = if x < y then x else y

fun selectColour (colours: [n]pixel) (x: int): pixel =
  let range = 256 / n
  in unsafe colours[min (x/range) (n-1)]

entry warhol(frame : [h][w]pixel, _distortion : f32) : [h][w]pixel =
  let colours = [[0u8,0u8,255u8], [255u8,0u8,255u8], [255u8,165u8,0u8], [255u8,255u8,0u8]]
  in map (fn row : [w]pixel =>
            map (selectColour colours) (map intensity row))
          frame
