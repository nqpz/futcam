fun max32 (x: u32) (y: u32): u32 = if x < y then y else x

fun indexOfMax32 ((x,i): (u32,int)) ((y,j): (u32,int)): (u32,int) =
  if x < y then (y,j) else (x,i)

fun beforeMax ((max_v, max_i): (u32, int)) ((v,i): (u32, int)): u32 =
  if i < max_i then v else max_v

entry mystery(frame : [h][w]pixel) : [h][w]pixel =
  map (fn row: [w]pixel =>
         let (rs,gs,bs) = unzip (map get_rgb row)
         let rms = reduce indexOfMax32 (0u32,0) (zip rs (iota w))
         let gms = reduce indexOfMax32 (0u32,0) (zip gs (iota w))
         let bms = reduce indexOfMax32 (0u32,0) (zip bs (iota w))
         let rs' = map (beforeMax rms) (zip rs (iota w))
         let gs' = map (beforeMax gms) (zip gs (iota w))
         let bs' = map (beforeMax bms) (zip bs (iota w))
         in zipWith (fn r g b => set_rgb (r,g,b)) rs' gs' bs')
   frame
