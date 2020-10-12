import "base"
import "misc"
module W = import "warhol"

let desaturate (p: pixel): pixel =
  let v = W.intensity p
  in set_rgb v v v

let rotation ((x,y): (i32, i32)): f32 =
  let r = f32.sqrt (r32 (x*x + y*y))
  let x' = r32 x / r
  let y' = r32 y / r
  in f32.atan2 y' x'

let greyscale [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  map (\x: [w]pixel ->
         map (\y ->
                let p = frame[x, y]
                in if rotation (x-i32.i64 h/2, y-i32.i64 w/2) < distortion+3.147
                   then desaturate p
                   else p)
             (map i32.i64 (iota w)))
      (map i32.i64 (iota h))
