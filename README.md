# futcam

Run Futhark code on a live webcam feed!

Run `make` to build the library, and then run `./futcam.py` to run the
program.  Run `./futcam.py --help` to see which settings exist.

Futhark: http://futhark-lang.org/ and
https://github.com/HIPERFIT/futhark


## Dependencies

`futcam.py` depends on Python 3, PyGame, NumPy, and OpenCV.


## Keyboard controls

Use up and down arrow keys to navigate the filters.

Use left and right arrow keys to adjust a special variable sent to some
of the filters.

Press Enter to activate a filter.  Press backspace to deactivate it.

Press `h` to toggle the HUD.

Press `q` to exit.
