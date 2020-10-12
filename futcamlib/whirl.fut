import "base"

let toSq   (w: i32) (x: i32): f32 = 2.0*r32 x/r32 w - 1.0
let fromSq (w: i32) (x: f32): i32 = t32 ((x+1.0)*r32 w/2.0)
let sqIndex [h][w] (frame: [h][w]pixel) ((x,y): (f32,f32)): pixel =
  let x' = fromSq (i32.i64 h) x
  let y' = fromSq (i32.i64 w) y
  in if x' >= 0 && x' < (i32.i64 h) && y' >= 0 && y' < (i32.i64 w)
     then frame[x', y']
     else RGB.black

let whirl [h][w] (frame: [h][w]pixel) (distortion: f32): [h][w]pixel =
  map (\x: [w]pixel ->
         map (\y: pixel ->
                let r = f32.sqrt (x*x + y*y)
                let a = distortion-r
                let c = f32.cos a
                let s = f32.sin a
                let x' = x*c-y*s
                let y' = x*s+y*c
                in sqIndex frame (x',y'))
             (map (toSq (i32.i64 w)) (map i32.i64 (iota w))))
      (map (toSq (i32.i64 h)) (map i32.i64 (iota h)))
