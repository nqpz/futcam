# Misc. Futhark fun

Futhark: http://futhark-lang.org/ and
https://github.com/HIPERFIT/futhark


## futcam.py

Run Futhark code on a live webcam feed!

Run `make` to build the library, and then run `./futcam.py` to run the
program.


### Dependencies

`futcam.py` depends on PyGame, NumPy, and OpenCV 2.


### Keyboard controls

Use up and down arrow keys to navigate the filters.

Use left and right arrow keys to adjust a special variable sent to some
of the filters.

Press Enter to activate a filter.  Press backspace to deactivate it.

Press `q` to exit.
