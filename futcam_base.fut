default (f32)

type pixel = [3]u8 -- Well, it works.

struct RGB {
val black: pixel   = [  0u8,  0u8,  0u8]
val white: pixel   = [255u8,255u8,255u8]
val red: pixel     = [255u8,  0u8,  0u8]
val green: pixel   = [  0u8,  255u8,0u8]
val blue: pixel    = [  0u8,  0u8,255u8]
val yellow: pixel  = [255u8,255u8,  0u8]
val cyan: pixel    = [  0u8,255u8,255u8]
val magenta: pixel = [255u8,  0u8,255u8]
val orange: pixel  = [255u8,165u8,  0u8]
val pink: pixel    = [255u8,192u8,203u8]
val purple: pixel  = [128u8,  0u8,128u8]
}
