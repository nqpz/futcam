import "base"

let max32 (x: i32) (y: i32): i32 = if x < y then y else x

let indexOfMax32 ((x,i): (i32,i32)) ((y,j): (i32,i32)): (i32,i32) =
  if x < y then (y,j) else (x,i)

let beforeMax ((max_v, max_i): (i32, i32)) ((v,i): (i32, i32)): i32 =
  if i < max_i then v else max_v

let mystery [h][w] (frame: [h][w]pixel): [h][w]pixel =
  map (\row: [w]pixel ->
         let (rs,gs,bs) = unzip3 (map get_rgb row)
         let rms = reduce indexOfMax32 (0,0) (zip rs (iota w))
         let gms = reduce indexOfMax32 (0,0) (zip gs (iota w))
         let bms = reduce indexOfMax32 (0,0) (zip bs (iota w))
         let rs' = map (beforeMax rms) (zip rs (iota w))
         let gs' = map (beforeMax gms) (zip gs (iota w))
         let bs' = map (beforeMax bms) (zip bs (iota w))
         in map3 (\r g b -> set_rgb r g b) rs' gs' bs')
   frame
