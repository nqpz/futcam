default (f32)

type pixel = u32
type channel = u32 -- This should only be 0..255, but u32 is fine.

fun get_r(p : pixel) : channel =
  (p >> 16u32) & 255u32

fun set_r(p : pixel, c : channel) : pixel =
  (p | (255u32 << 16u32)) & (c << 16u32)

fun get_g(p : pixel) : channel =
  (p >> 8u32) & 255u32

fun set_g(p : pixel, c : channel) : pixel =
  (p | (255u32 << 8u32)) & (c << 8u32)

fun get_b(p : pixel) : channel =
  p & 255u32

fun set_b(p : pixel, c : channel) : pixel =
  (p | 255u32) & c

fun get_rgb(p : pixel) : (channel, channel, channel) =
  (get_r p, get_g p, get_b p)

fun set_rgb(r : channel, g : channel, b : channel) : pixel =
  (r << 16u32) | (g << 8u32) | b

module RGB {
  val black: pixel   = set_rgb(  0u32,  0u32,  0u32)
  val white: pixel   = set_rgb(255u32,255u32,255u32)
  val red: pixel     = set_rgb(255u32,  0u32,  0u32)
  val green: pixel   = set_rgb(  0u32,  255u32,0u32)
  val blue: pixel    = set_rgb(  0u32,  0u32,255u32)
  val yellow: pixel  = set_rgb(255u32,255u32,  0u32)
  val cyan: pixel    = set_rgb(  0u32,255u32,255u32)
  val magenta: pixel = set_rgb(255u32,  0u32,255u32)
  val orange: pixel  = set_rgb(255u32,165u32,  0u32)
  val pink: pixel    = set_rgb(255u32,192u32,203u32)
  val purple: pixel  = set_rgb(128u32,  0u32,128u32)
}
