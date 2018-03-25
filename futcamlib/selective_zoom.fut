import "/futlib/math"
import "base"
import "misc"
import "color"
default (f32)

type pixel_set_single = (i32, pixel)
type pixel_set = [4]pixel_set_single

let to_index (h : i32) (w : i32) (y : i32) (x : i32) : i32 =
  if y < 0 || y >= h || x < 0 || x >= w
  then -1
  else y * w + x

let selective_zoom_pixel (h : i32) (w : i32)
  (index : i32) (p : pixel) (m : bool) : pixel_set =
  if m then let y = index / w
            let x = index % w
            let y_norm = y - h / 2
            let x_norm = x - w / 2
            let y_norm' = y_norm * 2
            let x_norm' = x_norm * 2
            let y' = y_norm' + h / 2
            let x' = x_norm' + w / 2
            let upper_upper = to_index h w (y'    ) (x'    )
            let upper_lower = to_index h w (y'    ) (x' - 1)
            let lower_upper = to_index h w (y' - 1) (x'    )
            let lower_lower = to_index h w (y' - 1) (x' - 1)
            let indices = [upper_upper, upper_lower, lower_upper, lower_lower]
            in zip indices (replicate 4 p)
  else replicate 4 (-1, 0)

let hue_difference (h0 : f32) (h1 : f32) : f32 =
  let (h0, h1) = if h1 < h0 then (h1, h0) else (h0, h1)
  in f32.min (h1 - h0) (h0 + 360.0 - h1)

let selective_zoom [h][w] (frame : *[h][w]pixel) (threshold: f32) : [h][w]pixel =
  let n = h * w
  let pixels = reshape (n) frame
  let mask = map (\(p : pixel) : bool ->
                    let (_h, _s, v) = get_hsv p
                    -- let okay = hue_difference h (threshold * 10.0) < 50.0
                    -- let okay = s > threshold / 10.0
                    let okay = v > threshold / 10.0
                    in okay)
                 pixels
  let pixel_sets = map3 (selective_zoom_pixel h w) (iota n) pixels mask
  let (indices, pixel_writes) = unzip (reshape (n * 4) pixel_sets)
  let pixels' = scatter pixels indices pixel_writes
  let pixels'' = reshape (h, w) pixels'
  in pixels''
