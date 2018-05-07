import "/futlib/math"
import "base"
import "color"

let neighbors_relative (breadth: i32): [](i32, i32) =
  flatten
  (map (\y -> map (\x -> (y, x)) (-breadth...breadth)) (-breadth...breadth))

let oil_painting [h][w] (frame: [h][w]pixel) (breadth: i32): [h][w]pixel =
  let ns = neighbors_relative (i32.max 0 breadth)
  let oil_painting_pixel_at (y: i32) (x: i32): pixel =
    let ns' = map (\(yrel, xrel) -> (y + yrel, x + xrel)) ns
    let ps = map (\(y0, x0) ->
                  let y1 = i32.max 0 (i32.min (h - 1) y0)
                  let x1 = i32.max 0 (i32.min (w - 1) x0)
                  in unsafe frame[y1, x1]) ns'
    let hsvs = map get_hsv ps
    in (reduce_comm (\(p0, (h0, s0, v0)) (p1, (h1, s1, v1)) ->
                     if s0 > s1
                     then (p0, (h0, s0, v0))
                     else (p1, (h1, s1, v1)))
        (0, (0.0, 0.0, 0.0)) (zip ps hsvs)).1

  in map (\(y: i32): [w]pixel ->
       map (\(x: i32): pixel -> oil_painting_pixel_at y x)
       (0..<w))
  (0..<h)
