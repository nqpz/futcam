import "misc"
import "base"

let intensity (p: pixel): i32 =
  let (r, g, b) = get_rgb(p)
  in (r * 2 + g * 3 + b) / 6

let selectColour [n] (colours: [n]pixel) (x: i32): pixel =
  let n = i32.i64 n
  let range = 256 / n
  in colours[i64.i32 (i32.min (x/range) (n-1))]

let warholColourise [n][h][w] (colours: [n]pixel) (frame: [h][w]pixel): [h][w]pixel =
  map (\row: [w]pixel -> map (selectColour colours) (map intensity row))
      frame

let concat_to 't (n: i64) (xs: []t) (ys: []t): *[]t = xs ++ ys :> [n]t

let warhol [h][w] (frame: [h][w]pixel): [h][w]pixel =
  let frame' = quad frame
  let (urows,lrows) = split (frame' :> [(h/2) + (h-(h/2))][w]pixel)
  let ul = urows[:,:w/2]
  let ur = urows[:,w/2:]
  let ll = lrows[:,:w/2]
  let lr = lrows[:,w/2:]
  let colours_ul = [RGB.blue, RGB.magenta, RGB.orange, RGB.yellow]
  let colours_ur = [RGB.cyan, RGB.pink, RGB.red, RGB.purple, RGB.black]
  let colours_ll = [RGB.orange, RGB.purple, RGB.cyan, RGB.blue]
  let colours_lr = [RGB.magenta, RGB.green, RGB.white, RGB.yellow]
  let ul' = warholColourise colours_ul ul
  let ur' = warholColourise colours_ur ur
  let ll' = warholColourise colours_ll ll
  let lr' = warholColourise colours_lr lr
  let lrows' = map2 (concat_to w) ll' lr'
  let urows' = map2 (concat_to w) ul' ur'
  in concat_to h urows' lrows'
