# You can run nix-shell in this directory if you have Nix installed.

with import <nixpkgs> {};
stdenv.mkDerivation {
    name = "futcam";
    buildInputs = [ pkgconfig SDL2 SDL2_ttf ocl-icd opencl-headers (python3.withPackages (ps: with ps; [ setuptools numpy pygame pyopencl opencv4 ])) ];
}
