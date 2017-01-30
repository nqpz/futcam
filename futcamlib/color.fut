import "futcamlib/base"
default (f32)

fun minf (a : f32, b : f32) : f32 =
  if a < b then a else b

fun maxf (a : f32, b : f32) : f32 =
  if a > b then a else b

fun absf (a : f32) : f32 =
  if a < 0.0 then -a else a

fun modf (a : f32, m : f32) : f32 =
  a - f32 (i32 (a / m)) * m
  
fun get_hsv (p : pixel) : (f32, f32, f32) =
  let (r0, g0, b0) = get_rgb p
  let (r, g, b) = (f32 r0 / 255.0, f32 g0 / 255.0, f32 b0 / 255.0)
  let mini = minf (minf (r, g), b)
  let maxi = maxf (maxf (r, g), b)
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

fun hsv_to_rgb (h : f32, s : f32, v : f32) : (u32, u32, u32) =
  let c = v * s
  let h' = h / 60.0
  let x = c * (1.0 - absf (modf (h', 2.0) - 1.0))
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
  in (u32 (255.0 * r), u32 (255.0 * g), u32 (255.0 * b))
