import "base"
import "color"

let quad [h][w] (frame: [h][w]pixel): [h][w]pixel =
  let n = 2
  in map (\y: [w]pixel ->
            map (\x: pixel -> frame[y%(h/n)*n,x%(w/n)*n])
                (iota w))
         (iota h)

let invert_rgb [h][w] (frame: [h][w]pixel): [h][w]pixel =
  map (\(row: [w]pixel): [w]pixel ->
         map (\(p: pixel): pixel ->
                let (r, g, b) = get_rgb p
                let r' = 255 - r
                let g' = 255 - g
                let b' = 255 - b
                in set_rgb r' g' b')
             row)
      frame

let balance_white [h][w] (frame: [h][w]pixel) (value_target: f32): [h][w]pixel =
  let len = h * w
  let pixels = flatten frame
  let value_total =
    reduce (+) 0.0
           (map (\(p: pixel): f32 ->
                   let (_h, _s, v) = get_hsv p
                   in v) pixels)
  let value_current = value_total / f32.i64 len
  let value_diff = value_target - value_current
  let pixels' = map (\(p: pixel): pixel ->
                       let (h, s, v) = get_hsv p
                       let (r, g, b) = hsv_to_rgb (h, s, f32.min 1.0 (v + value_diff))
                       in set_rgb r g b) pixels
  in unflatten pixels'

let balance_saturation [h][w] (frame: [h][w]pixel) (sat_target: f32): [h][w]pixel =
  let len = h * w
  let pixels = flatten frame
  let sat_total =
    reduce (+) 0.0
           (map (\(p: pixel): f32 ->
                   let (_h, s, _v) = get_hsv p
                   in s) pixels)
  let sat_current = sat_total / f32.i64 len
  let sat_diff = sat_target - sat_current
  let pixels' = map (\(p: pixel): pixel ->
                       let (h, s, v) = get_hsv p
                       let (r, g, b) = hsv_to_rgb (h, f32.max 0.0 (f32.min 1.0 (s + sat_diff)), v)
                       in set_rgb r g b) pixels
  in unflatten pixels'

let dim_sides [h][w] (frame: [h][w]pixel) (strength: f32): [h][w]pixel =
  map (\(row: [w]pixel, y: i64): [w]pixel ->
         map (\(pixel: pixel, x: i64): pixel ->
                let x_center_closeness = 1.0f32 - r32 (i32.abs (i32.i64 w / 2 - i32.i64 x)) / (r32 (i32.i64 w / 2))
                let y_center_closeness = 1.0f32 - r32 (i32.abs (i32.i64 h / 2 - i32.i64 y)) / (r32 (i32.i64 h / 2))
                let center_closeness = x_center_closeness * y_center_closeness
                let center_closeness' = center_closeness ** strength
                let (r, g, b) = get_rgb pixel
                let r' = i32.f32 (f32.i32 r * center_closeness')
                let g' = i32.f32 (f32.i32 g * center_closeness')
                let b' = i32.f32 (f32.i32 b * center_closeness')
                in set_rgb r' g' b')
             (zip row (iota w)))
      (zip frame (iota h))

let closeness_hue (h0: f32) (h1: f32): f32 =
  let (h0, h1) = if h1 < h0 then (h1, h0) else (h0, h1)
  let linear = 1.0 - f32.min (h1 - h0) (h0 + 360.0 - h1) / (360.0 / 2.0)
  let force = 3.3
  in linear ** force

let hue_focus [h][w] (frame: [h][w]pixel) (hue_focus: f32): [h][w]pixel =
  let hue_focus = fmod (fmod hue_focus 360.0 + 360.0) 360.0 in
  map (\(row: [w]pixel): [w]pixel ->
         map (\(p: pixel): pixel ->
                let (h, _s, _v) = get_hsv p
                let c = closeness_hue h hue_focus
                let h' = hue_focus
                let s' = c
                let v' = c
                let (r, g, b) = hsv_to_rgb (h', s', v')
                in set_rgb r g b)
             row)
      frame

let closeness_value (v0: f32) (v1: f32): f32 =
  f32.abs (v1 - v0)

let value_focus [h][w] (frame: [h][w]pixel) (value_focus: f32): [h][w]pixel =
  map (\(row: [w]pixel): [w]pixel ->
         map (\(p: pixel): pixel ->
                let (_h, _s, v) = get_hsv p
                let c = closeness_value v value_focus
                let h' = 0.0
                let s' = 0.0
                let v' = c
                let (r, g, b) = hsv_to_rgb (h', s', v')
                in set_rgb r g b)
             row)
      frame

let saturation_focus [h][w] (frame: [h][w]pixel) (value_focus: f32): [h][w]pixel =
  map (\(row: [w]pixel): [w]pixel ->
         map (\(p: pixel): pixel ->
                let (_h, s, _v) = get_hsv p
                let c = closeness_value s value_focus
                let h' = 0.0
                let s' = 0.0
                let v' = c
                let (r, g, b) = hsv_to_rgb (h', s', v')
                in set_rgb r g b)
             row)
      frame

let merge_colors [h][w] (frame: [h][w]pixel) (group_size: f32): [h][w]pixel =
  map (\(row: [w]pixel): [w]pixel ->
         map (\(p: pixel): pixel ->
                let (h, s, v) = get_hsv p
                let h' = r32 (t32 (h / group_size)) * group_size
                let s' = (r32 (t32 ((s * 360.0) / group_size)) * group_size) / 360.0
                let v' = (r32 (t32 ((v * 360.0) / group_size)) * group_size) / 360.0
                let (r, g, b) = hsv_to_rgb (h', s', v')
                in set_rgb r g b)
             row)
      frame

let equalise_saturation [h][w] (frame: [h][w]pixel): [h][w]pixel =
  map (\(row: [w]pixel): [w]pixel ->
         map (\(p: pixel): pixel ->
                let (h, _s, v) = get_hsv p
                let h' = h
                let s' = 0.5
                let v' = v
                let (r, g, b) = hsv_to_rgb (h', s', v')
                in set_rgb r g b)
             row)
      frame

let small_enough (threshold: i32) (a: i32) (b: i32): i32 =
  if a < b
  then if a <= threshold
       then b
       else a
  else if b <= threshold
  then a
  else b

let nth_smallest [n] (xs: [n]i32, nth: i32): i32 =
  let smallest = reduce i32.min xs[0] xs
  in loop (smallest) for _i < nth do
       reduce (small_enough smallest) smallest xs

let median [n] (xs: [n]i32): i32 = nth_smallest(xs, i32.i64 (n / 2))

let safe (x: i64, m: i64): i64 =
  if x < 0
  then 0
  else if x > m - 1
  then m - 1
  else x

let median_filter [h][w] (frame: [h][w]pixel) (iterations: i32): [h][w]pixel =
  let frame = loop (frame) for _i < iterations do
                map (\(y: i64): [w]pixel ->
                       map (\(x: i64): pixel ->
                              let um = frame[safe(y - 1, h), x]
                              let ur = frame[safe(y - 1, h), safe(x + 1, w)]
                              let cr = frame[y,              safe(x + 1, w)]
                              let lr = frame[safe(y + 1, h), safe(x + 1, w)]
                              let lm = frame[safe(y + 1, h), x]
                              let ll = frame[safe(y + 1, h), safe(x - 1, w)]
                              let cl = frame[y,              safe(x - 1, w)]
                              let ul = frame[safe(y - 1, h), safe(x - 1, w)]
                              let neighbors = [um, ur, cr, lr, lm, ll, cl, ul]
                              let p = median neighbors
                              in p)
                           (iota w))
                    (iota h)
  in frame

let pixel_average [n] (pixels: [n]i32): i32 =
  let rgbs = map get_rgb pixels
  let (r0, g0, b0) = reduce (\(a0, b0, c0) (a1, b1, c1) ->
                               (a0 + a1, b0 + b1, c0 + c1)) (0, 0, 0)
                            rgbs
  in set_rgb (r0 / i32.i64 n) (g0 / i32.i64 n) (b0 / i32.i64 n)

let simple_blur [h][w] (frame: [h][w]pixel) (iterations: i32): [h][w]pixel =
  let frame = loop (frame) for _i < iterations do
                map (\(y: i64): [w]pixel ->
                       map (\(x: i64): pixel ->
                              let um = frame[safe(y - 1, h), x]
                              let ur = frame[safe(y - 1, h), safe(x + 1, w)]
                              let cr = frame[y,              safe(x + 1, w)]
                              let lr = frame[safe(y + 1, h), safe(x + 1, w)]
                              let lm = frame[safe(y + 1, h), x]
                              let ll = frame[safe(y + 1, h), safe(x - 1, w)]
                              let cl = frame[y,              safe(x - 1, w)]
                              let ul = frame[safe(y - 1, h), safe(x - 1, w)]
                              let neighbors = [um, ur, cr, lr, lm, ll, cl, ul]
                              let p = pixel_average neighbors
                              in p)
                           (iota w))
                    (iota h)
  in frame

let hsv_distance (p0: pixel) (p1: pixel): f32 =
  let (h0, s0, v0) = get_hsv p0
  let (h1, s1, v1) = get_hsv p1
  let (h0, h1) = if h0 < h1
                 then (h0, h1)
                 else (h1, h0)
  let h_diff = f32.min (h1 - h0) (h0 + 360.0 - h1)
  let s_diff = f32.abs (s1 - s0)
  let v_diff = f32.abs (v1 - v0)
  in h_diff * s_diff * v_diff

let fake_heatmap [h][w] (frame: [h][w]pixel): [h][w]pixel =
  map (\(y: i64): [w]pixel ->
         map (\(x: i64): pixel ->
                let cm = frame[y, x]

                let um = frame[safe(y - 1, h), x]
                let ur = frame[safe(y - 1, h), safe(x + 1, w)]
                let cr = frame[y,              safe(x + 1, w)]
                let lr = frame[safe(y + 1, h), safe(x + 1, w)]
                let lm = frame[safe(y + 1, h), x]
                let ll = frame[safe(y + 1, h), safe(x - 1, w)]
                let cl = frame[y,              safe(x - 1, w)]
                let ul = frame[safe(y - 1, h), safe(x - 1, w)]

                let neighbors = [um, ur, cr, lr, lm, ll, cl, ul]
                let dist_total = reduce (+) 0.0 (map (hsv_distance cm) neighbors)
                let dist_max = 180.0 * 8.0
                let factor_base = dist_total / dist_max
                let factor_rest = 1.0 - factor_base

                let (h_in, s_in, v_in) = get_hsv cm
                let (h_out, s_out, v_out) =
                  (h_in,
                   s_in * factor_base + factor_rest,
                   v_in * factor_base + factor_rest)
                let (r_out, g_out, b_out) = hsv_to_rgb (h_out, s_out, v_out)
                in set_rgb r_out g_out b_out)
             (iota w))
      (iota h)

let insane_blur [h][w] (insaneness: i32) (frame: [h][w]pixel) (xc: i32) (yc: i32): pixel =
  let half_insaneness = insaneness / 2
  let x_start = xc - half_insaneness
  let y_start = yc - half_insaneness
  let xs = map (\ins -> i32.i64 ins + x_start) (iota (i64.i32 insaneness))
  let ys = map (\ins -> i32.i64 ins + y_start) (iota (i64.i32 insaneness))
  in pixel_average (
       map (\y ->
              pixel_average (map (\x ->
                                    frame[safe(i64.i32 y, h), safe(i64.i32 x, w)])
                                 xs))
           ys)

let blur_low_color [h][w] (frame: [h][w]pixel) (threshold: f32): [h][w]pixel =
  map (\(y: i64): [w]pixel ->
         map (\(x: i64): pixel ->
                let p = frame[y,x]
                let (_h, s, _v) = get_hsv p
                let p' = if s < threshold
                         then insane_blur 40 frame (i32.i64 x) (i32.i64 y)
                         else p
                in p')
             (iota w))
      (iota h)

let colored_boxes [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  let rect_size = t32 distortion
  let w_n = (i32.i64 w / rect_size + i32.sgn (i32.i64 w % rect_size)) in
  map2 (\(row: [w]pixel) (y: i64): [w]pixel ->
          map2 (\(p: pixel) (x: i64): pixel ->
                  let x_n = i32.i64 x / rect_size
                  let y_n = i32.i64 y / rect_size
                  let t = y_n * w_n + x_n
                  let (h, s, v) = get_hsv p
                  let h' = fmod (h + r32 t * 20.0) 360.0
                  let (s_min, s_max) = if s > 0.5
                                       then (1.0 - s, s)
                                       else (s, 1.0 - s)
                  let (v_min, v_max) = if v > 0.5
                                             then (1.0 - v, v)
                                             else (v, 1.0 - v)
                        let s' = f32.min s_max (f32.max s_min (fmod (s + r32 t * 0.05) 1.0))
                        let v' = f32.min v_max (f32.max v_min (fmod (v + r32 t * 0.05) 1.0))
                        let (r, g, b) = hsv_to_rgb (h', s', v')
                        in set_rgb r g b)
                     row (iota w))
          frame (iota h)
