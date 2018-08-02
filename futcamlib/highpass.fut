-- Fancy highpass filter that removes certain colours.

import "/futlib/complex"

module c32 = complex f32
type c32 = c32.complex

import "/futlib/fft"

module fft = mk_fft f32

let centre_2d [n][m] (arr: [n][m]c32): [n][m]c32 =
  let f (i: i32) (j: i32) (x: c32) =
        c32.mk_re (f32.i32 ((-1) ** (i+j))) c32.* x
  in map (\(i,r) -> map (\(j,x) -> f i j x) (zip (iota m) r)) (zip (iota n) arr)

let transform [n][m] (cutoff: i32) (arr: [n][m]u8) =
  let arr_complex = map (\r -> map c32.mk_re (map f32.u8 r)) arr
  let arr_centered = centre_2d arr_complex
  let arr_freq = fft.fft2 arr_centered
  let centre_i = n / 2
  let centre_j = m / 2
  let zap (i: i32) (j: i32) (x: c32) =
        if i > centre_i - cutoff && i < centre_i + cutoff &&
           j > centre_j - cutoff && j < centre_j + cutoff
        then c32.mk_re 0f32 else x
  let arr_filt = map (\(i,r) -> map (\(j,x) -> zap i j x) (zip (iota m) r))
                     (zip (iota n) arr_freq)
  let arr_inv = fft.ifft2 arr_filt
  in map (\r -> map u8.f32 (map c32.mag r)) arr_inv

import "base"

let unpack_rgb (x: pixel): (u8, u8, u8) =
  let (r, g, b) = get_rgb x
  in (u8.i32 r, u8.i32 g, u8.i32 b)

let pack_rgb ((r,g,b): (u8, u8, u8)): pixel =
  set_rgb (i32.u8 r) (i32.u8 g) (i32.u8 b)

let highpass [n][m] (img: [n][m]pixel) (cutoff: i32): [n][m]pixel =
  let (r, g, b) = unzip3 (map (\t -> unzip3 (map unpack_rgb t)) img)
  let r' = transform cutoff r
  let g' = transform cutoff g
  let b' = transform cutoff b
  in map3 (\r'' g'' b'' -> map pack_rgb (zip3 r'' g'' b'')) r' g' b'
