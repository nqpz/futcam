import "/futlib/math"
import "base"
default (f32)

let toSq   (w: i32) (x: i32): f32 = 2.0*r32 x/r32 w - 1.0
let fromSq (w: i32) (x: f32): i32 = t32 ((x+1.0)*r32 w/2.0)
let sqIndex [h][w] (frame: [h][w]pixel) ((x,y): (f32,f32)): pixel =
  let x' = fromSq h x
  let y' = fromSq w y
  in if x' >= 0 && x' < h && y' >= 0 && y' < w
     then unsafe frame[x', y']
     else RGB.black

entry whirl [h][w] (frame: [h][w]pixel, distortion: f32): [h][w]pixel =
  map (\x: [w]pixel ->
         map (\y: pixel ->
                let r = f32.sqrt (x*x + y*y)
                let a = distortion-r
                let c = f32.cos a
                let s = f32.sin a
                let x' = x*c-y*s
                let y' = x*s+y*c
                in sqIndex frame (x',y'))
             (map (toSq w) (iota w)))
      (map (toSq h) (iota h))
