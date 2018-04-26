type pixel = i32
type channel = i32 -- This should only be 0..255, but i32 is fine.

let get_r (p: pixel): channel =
  (p >> 16) & 255

let set_r (p: pixel) (c: channel): pixel =
  (p | (255 << 16)) & (c << 16)

let get_g (p: pixel): channel =
  (p >> 8) & 255

let set_g (p: pixel) (c: channel): pixel =
  (p | (255 << 8)) & (c << 8)

let get_b (p: pixel): channel =
  p & 255

let set_b (p: pixel) (c: channel): pixel =
  (p | 255) & c

let get_rgb (p: pixel): (channel, channel, channel) =
  (get_r p, get_g p, get_b p)

let set_rgb (r: channel) (g: channel) (b: channel): pixel =
  (r << 16) | (g << 8) | b

module RGB = {
  let black: pixel   = set_rgb   0   0   0
  let white: pixel   = set_rgb 255 255 255
  let red: pixel     = set_rgb 255   0   0
  let green: pixel   = set_rgb   0   255 0
  let blue: pixel    = set_rgb   0   0 255
  let yellow: pixel  = set_rgb 255 255   0
  let cyan: pixel    = set_rgb   0 255 255
  let magenta: pixel = set_rgb 255   0 255
  let orange: pixel  = set_rgb 255 165   0
  let pink: pixel    = set_rgb 255 192 203
  let purple: pixel  = set_rgb 128   0 128
}
