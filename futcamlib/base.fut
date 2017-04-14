default (f32)

type pixel = u32
type channel = u32 -- This should only be 0..255, but u32 is fine.

let get_r (p: pixel): channel =
  (p >> 16u32) & 255u32

let set_r (p: pixel) (c: channel): pixel =
  (p | (255u32 << 16u32)) & (c << 16u32)

let get_g (p: pixel): channel =
  (p >> 8u32) & 255u32

let set_g (p: pixel) (c: channel): pixel =
  (p | (255u32 << 8u32)) & (c << 8u32)

let get_b (p: pixel): channel =
  p & 255u32

let set_b (p: pixel) (c: channel): pixel =
  (p | 255u32) & c

let get_rgb (p: pixel): (channel, channel, channel) =
  (get_r p, get_g p, get_b p)

let set_rgb (r: channel) (g: channel) (b: channel): pixel =
  (r << 16u32) | (g << 8u32) | b

module RGB = {
  let black: pixel   = set_rgb   0u32   0u32   0u32
  let white: pixel   = set_rgb 255u32 255u32 255u32
  let red: pixel     = set_rgb 255u32   0u32   0u32
  let green: pixel   = set_rgb   0u32   255u32 0u32
  let blue: pixel    = set_rgb   0u32   0u32 255u32
  let yellow: pixel  = set_rgb 255u32 255u32   0u32
  let cyan: pixel    = set_rgb   0u32 255u32 255u32
  let magenta: pixel = set_rgb 255u32   0u32 255u32
  let orange: pixel  = set_rgb 255u32 165u32   0u32
  let pink: pixel    = set_rgb 255u32 192u32 203u32
  let purple: pixel  = set_rgb 128u32   0u32 128u32
}
