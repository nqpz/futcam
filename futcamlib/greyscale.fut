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

entry greyscale(frame: [h][w]pixel, distortion: f32): [h][w]pixel =
  zipWith (\x: [w]pixel ->
             map (\y ->
                    let p = frame[x,y]
                    in if rotation (x-h/2, y-w/2) < distortion+3.147
                       then desaturate p
                       else p)
           (iota w))
   (iota h)
