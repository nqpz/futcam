.PHONY: all clean

all: futcam_transforms.py

futcam_transforms.py: futcam_transforms.fut
	futhark-pyopencl --library futcam_transforms.fut

clean:
	rm -f futcam_transforms.py
