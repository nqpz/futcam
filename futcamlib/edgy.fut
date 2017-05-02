import "/futlib/math"
import "futcamlib/base"

default (f32)

entry edgy (frame: [#h][#w]pixel,
            distortion: f32): [h][w]pixel =
  map (\x: [w]pixel ->
       map (\y ->
            if x >= w - 10
            then RGB.black
            else let (x1, x2) = (unsafe frame[x, y], unsafe frame[x + 10, y])
                 let r_grad   = u32.abs (get_r(x1) - get_r(x2))
                 let g_grad   = u32.abs (get_g(x1) - get_g(x2))
                 let b_grad   = u32.abs (get_b(x1) - get_b(x2))
                 let total_edge = 1.0 - f32 (r_grad + g_grad + b_grad) / (3.0f32 * 255.0f32)
                 let total_edge' = if total_edge > (distortion / 10.0) then 1.0 else 0.0
                 in set_rgb (u32 (total_edge' * 255.0)) (u32 (total_edge' * 255.0)) (u32 (total_edge' * 255.0))
           ) (iota w)) (iota h)
