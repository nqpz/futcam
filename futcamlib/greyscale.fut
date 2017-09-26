import "/futlib/math"
import "base"
import "misc"
module W = import "warhol"

default (f32)

let desaturate (p: pixel): pixel =
  let v = u32 (W.intensity p)
  in set_rgb v v v

let rotation ((x,y): (i32, i32)): f32 =
  let r = f32.sqrt (f32 (x*x + y*y))
  let x' = f32 x / r
  let y' = f32 y / r
  in f32.atan2 y' x'

entry greyscale [h][w] (frame: [h][w]pixel, distortion: f32): [h][w]pixel =
  map (\x: [w]pixel ->
             map (\y ->
                    let p = frame[x, y]
                    in if rotation (x-h/2, y-w/2) < distortion+3.147
                       then desaturate p
                       else p)
           (iota w))
   (iota h)
