include futcam_base

entry scale_to_simple(frame : [h0][w0]pixel, w1 : i32, h1 : i32) : [h1][w1]pixel =
  let y_factor = (f32 h1) / (f32 h0)
  let x_factor = (f32 w1) / (f32 w0)
  in map (fn (y1 : i32) : [w1]pixel =>
            map (fn (x1 : i32) : pixel =>
                   let y1_norm = f32 (y1 - h1 / 2)
                   let y0_norm = y1_norm / y_factor
                   let y0 = (i32 y0_norm) + h0 / 2

                   let x1_norm = f32 (x1 - w1 / 2)
                   let x0_norm = x1_norm / x_factor
                   let x0 = (i32 x0_norm) + w0 / 2

                   let pixel = unsafe frame[y0][x0]
                   in pixel)
         (iota w1))
  (iota h1)

type pixel_float = (f32, f32, f32)

fun pixel_float(pixel : pixel) : pixel_float =
  let (r, g, b) = get_rgb(pixel)
  in (f32 r, f32 g, f32 b)

fun pixel_unfloat(pixel : pixel_float) : pixel =
  let (r, g, b) = pixel
  in set_rgb(u32 r, u32 g, u32 b)

fun pixel_add(a : pixel_float, b : pixel_float) : pixel_float =
  let (r_a, g_a, b_a) = a
  let (r_b, g_b, b_b) = b
  in (r_a + r_b, g_a + g_b, b_a + b_b)

fun pixel_mult_factor(p : pixel_float, f : f32) : pixel_float =
  let (r, g, b) = p
  in (r * f, g * f, b * f)

entry scale_to_thoughtful(frame : [h0][w0]pixel, w1 : i32, h1 : i32) : [h1][w1]pixel =
  let y_factor = (f32 h1) / (f32 h0)
  let x_factor = (f32 w1) / (f32 w0)
  in map (fn (y1 : i32) : [w1]pixel =>
            map (fn (x1 : i32) : pixel =>
                   let y1_norm = f32 (y1 - h1 / 2)
                   let y0_norm = y1_norm / y_factor
                   let y0 = y0_norm + f32 (h0 / 2)

                   let x1_norm = f32 (x1 - w1 / 2)
                   let x0_norm = x1_norm / x_factor
                   let x0 = x0_norm + f32 (w0 / 2)

                   let y_effect_b = y0 - f32 (i32 y0)
                   let y_effect_a = 1.0f32 - y_effect_b
                   let y_index_a = i32 y0
                   let y_index_b = if y_index_a == h0 - 1
                                   then y_index_a
                                   else y_index_a + 1

                   let x_effect_b = x0 - f32 (i32 x0)
                   let x_effect_a = 1.0f32 - x_effect_b
                   let x_index_a = i32 x0
                   let x_index_b = if x_index_a == w0 - 1
                                   then x_index_a
                                   else x_index_a + 1

                   let y_val_0 =
                     pixel_add
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_a][x_index_a]), y_effect_a),
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_b][x_index_a]), y_effect_b)))

                   let y_val_1 =
                     pixel_add
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_a][x_index_b]), y_effect_a),
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_b][x_index_b]), y_effect_b)))

                   let x_val_0 =
                     pixel_add
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_a][x_index_a]), x_effect_a),
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_a][x_index_b]), x_effect_b)))

                   let x_val_1 =
                     pixel_add
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_b][x_index_a]), x_effect_a),
                       (pixel_mult_factor
                         (pixel_float (unsafe frame[y_index_b][x_index_b]), x_effect_b)))

                   let y_val = pixel_mult_factor (pixel_add (y_val_0, y_val_1), 0.5f32)
                   let x_val = pixel_mult_factor (pixel_add (x_val_0, x_val_1), 0.5f32)

                   let xy_val = pixel_mult_factor (pixel_add (y_val, x_val), 0.5f32)

                   let pixel = pixel_unfloat xy_val
                   in pixel)
         (iota w1))
  (iota h1)
