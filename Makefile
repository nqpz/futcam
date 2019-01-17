.PHONY: all clean

all: futcamlib.py

futcamlib.py: futcamlib.fut futcamlib/*.fut futcamlib/lib
	futhark pyopencl --library futcamlib.fut

futcamlib/lib: futcamlib/futhark.pkg
	cd futcamlib && futhark pkg sync

clean:
	rm -f futcamlib.py futcamlib.pyc
	rm -rf __pycache__ futcamlib/lib
