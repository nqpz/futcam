import "base"

type pixel_float = (f32, f32, f32)

let pixel_float (pixel: pixel): pixel_float =
  let (r, g, b) = get_rgb(pixel)
  in (r32 r, r32 g, r32 b)

let pixel_unfloat (pixel: pixel_float): pixel =
  let (r, g, b) = pixel
  in set_rgb (t32 r) (t32 g) (t32 b)

let pixel_add (a: pixel_float, b: pixel_float): pixel_float =
  let (r_a, g_a, b_a) = a
  let (r_b, g_b, b_b) = b
  in (r_a + r_b, g_a + g_b, b_a + b_b)

let pixel_mult_factor (p: pixel_float, f: f32): pixel_float =
  let (r, g, b) = p
  in (r * f, g * f, b * f)

let pixel_at [h][w] (frame: [h][w]pixel, x: f32, y: f32): pixel_float =
  let y_effect_b = y - r32 (t32 y)
  let y_effect_a = 1.0f32 - y_effect_b
  let y_index_a = t32 y
  let y_index_b = if y_index_a == h - 1
                  then y_index_a
                  else y_index_a + 1

  let x_effect_b = x - r32 (t32 x)
  let x_effect_a = 1.0f32 - x_effect_b
  let x_index_a = t32 x
  let x_index_b = if x_index_a == w - 1
                  then x_index_a
                  else x_index_a + 1

  let y_val_0 =
    pixel_add
    (pixel_mult_factor
     (pixel_float (frame[y_index_a,x_index_a]), y_effect_a),
     (pixel_mult_factor
      (pixel_float (frame[y_index_b,x_index_a]), y_effect_b)))

  let y_val_1 =
    pixel_add
    (pixel_mult_factor
     (pixel_float (frame[y_index_a,x_index_b]), y_effect_a),
     (pixel_mult_factor
      (pixel_float (frame[y_index_b,x_index_b]), y_effect_b)))

  let x_val_0 =
    pixel_add
    (pixel_mult_factor
     (pixel_float (frame[y_index_a,x_index_a]), x_effect_a),
     (pixel_mult_factor
      (pixel_float (frame[y_index_a,x_index_b]), x_effect_b)))

  let x_val_1 =
    pixel_add
    (pixel_mult_factor
     (pixel_float (frame[y_index_b,x_index_a]), x_effect_a),
     (pixel_mult_factor
      (pixel_float (frame[y_index_b,x_index_b]), x_effect_b)))

  let y_val = pixel_mult_factor (pixel_add (y_val_0, y_val_1), 0.5f32)
  let x_val = pixel_mult_factor (pixel_add (x_val_0, x_val_1), 0.5f32)

  let xy_val = pixel_mult_factor (pixel_add (y_val, x_val), 0.5f32)

  in xy_val
