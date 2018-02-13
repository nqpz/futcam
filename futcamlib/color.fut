import "/futlib/math"
import "base"
default (f32)

let fmod (a: f32) (m: f32): f32 =
  a - r32 (t32 (a / m)) * m

let get_hsv (p: pixel): (f32, f32, f32) =
  let (r0, g0, b0) = get_rgb p
  let (r, g, b) = (f32.i32 r0 / 255.0, f32.i32 g0 / 255.0, f32.i32 b0 / 255.0)
  let mini = f32.min (f32.min r g) b
  let maxi = f32.max (f32.max r g) b
  let v = maxi
  let s = if v != 0.0f32
          then (v - mini) / v
          else 0.0f32
  let h = if r >= g && r >= b
          then 60.0f32 * (g - b) / (v - mini)
          else if g >= r && g >= b
          then 120.0f32 + 60.0f32 * (b - r) / (v - mini)
          else 240.0f32 + 60.0f32 * (r - g) / (v - mini)
  let h' = if h < 0.0
           then h + 360.0
           else h
  in (h', s, v)

let hsv_to_rgb (h: f32, s: f32, v: f32): (i32, i32, i32) =
  let c = v * s
  let h' = h / 60.0
  let x = c * (1.0 - f32.abs (fmod h' 2.0 - 1.0))
  let (r0, g0, b0) = if 0.0 <= h' && h' < 1.0
                     then (c, x, 0.0)
                     else if 1.0 <= h' && h' < 2.0
                     then (x, c, 0.0)
                     else if 2.0 <= h' && h' < 3.0
                     then (0.0, c, x)
                     else if 3.0 <= h' && h' < 4.0
                     then (0.0, x, c)
                     else if 4.0 <= h' && h' < 5.0
                     then (x, 0.0, c)
                     else if 5.0 <= h' && h' < 6.0
                     then (c, 0.0, x)
                     else (0.0, 0.0, 0.0)
  let m = v - c
  let (r, g, b) = (r0 + m, g0 + m, b0 + m)
  in (i32.f32 (255.0 * r), i32.f32 (255.0 * g), i32.f32 (255.0 * b))
