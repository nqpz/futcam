.PHONY: all clean

all: futcamlib.py

futcamlib.py: futcamlib.fut
	futhark-pyopencl --library futcamlib.fut

clean:
	rm -f futcamlib.py
