include futcamlib.base
include futcamlib.scale
default (f32)

entry invert_rgb(frame : [h][w]pixel) : [h][w]pixel =
  map (fn (row : [w]pixel) : [w]pixel =>
         map (fn (p : pixel) : pixel =>
                let (r, g, b) = get_rgb p
                let r' = 255u32 - r
                let g' = 255u32 - g
                let b' = 255u32 - b
                in set_rgb (r', g', b'))
         row)
  frame

entry dim_sides(frame : [h][w]pixel, strength : f32) : [h][w]pixel =
  map (fn (row : [w]pixel, y : i32) : [w]pixel =>
         map (fn (pixel : pixel, x : i32) : pixel =>
                let x_center_closeness = 1.0f32 - f32 (abs (w / 2 - x)) / (f32 (w / 2))
                let y_center_closeness = 1.0f32 - f32 (abs (h / 2 - y)) / (f32 (h / 2))
                let center_closeness = x_center_closeness * y_center_closeness
                let center_closeness' = center_closeness ** strength 
                let (r, g, b) = get_rgb(pixel)
                let r' = u32 (f32 r * center_closeness')
                let g' = u32 (f32 g * center_closeness')
                let b' = u32 (f32 b * center_closeness')
                in set_rgb(r', g', b'))
         (zip row (iota w)))
  (zip frame (iota h))

entry fisheye(frame : [h][w]pixel, distortion : f32) : [h][w]pixel =
  map (fn (y : i32) : [w]pixel =>
         map (fn (x : i32) : pixel =>
                let y_scale = ((f32 (h / 2)) ** distortion) / (f32 (h / 2))
                let x_scale = ((f32 (w / 2)) ** distortion) / (f32 (w / 2))

                let y_norm_base = f32 (y - h / 2)
                let y_lz = y_norm_base < 0.0f32
                let y_norm = if y_lz then -y_norm_base else y_norm_base
                let y' = (y_norm ** distortion) / y_scale
                let y_back = i32 (if y_lz then -y' else y') + h / 2

                let x_norm_base = f32 (x - w / 2)
                let x_lz = x_norm_base < 0.0f32
                let x_norm = if x_lz then -x_norm_base else x_norm_base
                let x' = (x_norm ** distortion) / x_scale
                let x_back = i32 (if x_lz then -x' else x') + w / 2

                let pixel = unsafe frame[y_back][x_back]
                in pixel)
         (iota w))
  (iota h)

fun intensity (p: pixel): int =
  let (r, g, b) = get_rgb(p)
  in (int r * 2 + int g * 3 + int b) / 6

fun min (x: int) (y: int): int = if x < y then x else y

fun selectColour (colours: [n]pixel) (x: int): pixel =
  let range = 256 / n
  in unsafe colours[min (x/range) (n-1)]

entry warhol(frame : [h][w]pixel) : [h][w]pixel =
  let frame' = quad frame
  let (urows,lrows) = split (h/2) frame'
  let (ul,ur) = split@1 (w/2) urows
  let (ll,lr) = split@1 (w/2) lrows
  let colours_ul = [RGB.blue, RGB.magenta, RGB.orange, RGB.yellow]
  let colours_ur = [RGB.cyan, RGB.pink, RGB.red, RGB.purple, RGB.black]
  let colours_ll = [RGB.orange, RGB.purple, RGB.cyan, RGB.blue]
  let colours_lr = [RGB.magenta, RGB.green, RGB.white, RGB.yellow]
  let ul' = warholColourise colours_ul ul
  let ur' = warholColourise colours_ur ur
  let ll' = warholColourise colours_ll ll
  let lr' = warholColourise colours_lr lr
  let lrows' = concat@1 ll' lr'
  let urows' = concat@1 ul' ur'
  in concat urows' lrows'

fun warholColourise(colours: [n]pixel) (frame: [h][w]pixel): [h][w]pixel =
  map (fn row : [w]pixel => map (selectColour colours) (map intensity row))
      frame

entry quad(frame : [h][w]pixel) : [h][w]pixel =
  let n = 2
  in map (fn y: [w]pixel =>
            map (fn x : pixel => unsafe frame[y%(h/n)*n,x%(w/n)*n])
                (iota w))
         (iota h)

fun toSq   (w: int) (x: int): f32 = 2.0*f32 x/f32 w - 1.0
fun fromSq (w: int) (x: f32): int = int ((x+1.0)*f32 w/2.0)
fun sqIndex (frame: [h][w]pixel) ((x,y): (f32,f32)): pixel =
  let x' = fromSq h x
  let y' = fromSq w y
  in if x' >= 0 && x' < h && y' >= 0 && y' < w
     then unsafe frame[x', y']
     else set_rgb(0u32,0u32,0u32)

entry whirl(frame : [h][w]pixel, distortion : f32) : [h][w]pixel =
  map (fn x: [w]pixel =>
         map (fn y : pixel =>
                let r = sqrt32 (x*x + y*y)
                let a = distortion-r
                let c = cos32 a
                let s = sin32 a
                let x' = x*c-y*s
                let y' = x*s+y*c
                in sqIndex frame (x',y'))
             (map (toSq w) (iota w)))
      (map (toSq h) (iota h))

fun desaturate (p: pixel): pixel =
  let v = u32 (intensity p)
  in set_rgb(v,v,v)

fun rotation ((x,y): (int,int)): f32 =
  let r = sqrt32 (f32 (x*x + y*y))
  let x' = f32 x / r
  let y' = f32 y / r
  in atan2_32 y' x'

entry greyscale(frame: [h][w]pixel, distortion: f32): [h][w]pixel =
  zipWith (fn x: [w]pixel =>
             map (fn y =>
                    let p = frame[x,y]
                    in if rotation (x-h/2, y-w/2) < distortion+3.147
                       then desaturate p
                       else p)
           (iota w))
   (iota h)

-- fun max8 (x: u8) (y: u8): u8 = if x < y then y else x

-- entry prefixMax(frame : [h][w]pixel) : [h][w]pixel =
--   map (fn row: [w]pixel =>
--          let rs = row[0:w,0]
--          let gs = row[0:w,1]
--          let bs = row[0:w,2]
--          in transpose ([(scan max8 0u8 rs), (scan max8 0u8 gs), (scan max8 0u8 bs)]))
--    frame
