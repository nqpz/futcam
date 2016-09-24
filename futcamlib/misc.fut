include futcamlib.base
default (f32)

entry quad(frame : [h][w]pixel) : [h][w]pixel =
  let n = 2
  in map (fn y: [w]pixel =>
            map (fn x : pixel => unsafe frame[y%(h/n)*n,x%(w/n)*n])
                (iota w))
         (iota h)

entry invert_rgb(frame : [h][w]pixel) : [h][w]pixel =
  map (fn (row : [w]pixel) : [w]pixel =>
         map (fn (p : pixel) : pixel =>
                let (r, g, b) = get_rgb p
                let r' = 255u32 - r
                let g' = 255u32 - g
                let b' = 255u32 - b
                in set_rgb (r', g', b'))
         row)
  frame

entry dim_sides(frame : [h][w]pixel, strength : f32) : [h][w]pixel =
  map (fn (row : [w]pixel, y : i32) : [w]pixel =>
         map (fn (pixel : pixel, x : i32) : pixel =>
                let x_center_closeness = 1.0f32 - f32 (abs (w / 2 - x)) / (f32 (w / 2))
                let y_center_closeness = 1.0f32 - f32 (abs (h / 2 - y)) / (f32 (h / 2))
                let center_closeness = x_center_closeness * y_center_closeness
                let center_closeness' = center_closeness ** strength
                let (r, g, b) = get_rgb(pixel)
                let r' = u32 (f32 r * center_closeness')
                let g' = u32 (f32 g * center_closeness')
                let b' = u32 (f32 b * center_closeness')
                in set_rgb(r', g', b'))
         (zip row (iota w)))
  (zip frame (iota h))

-- fun max8 (x: u8) (y: u8): u8 = if x < y then y else x

-- entry prefixMax(frame : [h][w]pixel) : [h][w]pixel =
--   map (fn row: [w]pixel =>
--          let rs = row[0:w,0]
--          let gs = row[0:w,1]
--          let bs = row[0:w,2]
--          in transpose ([(scan max8 0u8 rs), (scan max8 0u8 gs), (scan max8 0u8 bs)]))
--    frame
