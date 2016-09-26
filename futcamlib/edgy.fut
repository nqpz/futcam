include futcamlib.base
default (f32)

fun desaturate (p: pixel): pixel =
  let v = u32 (intensity p)
  in set_rgb(v,v,v)

fun rotation ((x,y): (int,int)): f32 =
  let r = sqrt32 (f32 (x*x + y*y))
  let x' = f32 x / r
  let y' = f32 y / r
  in atan2_32 y' x'

  
entry edgy(frame: [h][w]pixel, distortion: f32): [h][w]pixel =
    zipWith (fn x: [w]pixel =>
               map (fn y =>
                      if (x == w-1)
                      then RGB.black
                      else
                        let two_pixels = (frame[x,y], frame[x+1,y])
                        let edgy_pixel =
                             let (x1, x2) = two_pixels
                             let r_grad   = abs (get_r(x1) - get_r(x2)) 
                             let g_grad   = abs (get_g(x1) - get_g(x2))
                             let b_grad   = abs (get_b(x1) - get_b(x2)) 
                             let total_edge = (r_grad + g_grad + b_grad) / (3.0f32 * 255.0f32)
                             in set_rgb(total_edge, total_edge, total_edge)
                          --                    in if rotation (x-h/2, y-w/2) < distortion+3.147
                          --                       then desaturate p
                          --                       else p)
                        in edgy_pixel
                   )
             (iota w-1))
             (iota h)