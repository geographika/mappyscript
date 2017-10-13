"""
http://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_setup/py_setup_in_windows/py_setup_in_windows.html#install-opencv-python-in-windows
http://www.lfd.uci.edu/~gohlke/pythonlibs/#opencv
http://www.lfd.uci.edu/~gohlke/pythonlibs/#numpy

pip install D:\Installation\opencv_python-3.3.0-cp36-cp36m-win_amd64.whl
opencv_python‑3.3.0‑cp36‑cp36m‑win_amd64.whl
D:\Installation\numpy-1.13.1+mkl-cp36-cp36m-win_amd64.whl

http://www.learnopencv.com/non-photorealistic-rendering-using-opencv-python-c/
http://docs.opencv.org/trunk/df/dac/group__photo__render.html
"""
import os
import numpy as np
import cv2

from PIL import Image

fld = r"C:\MapServer\apps\test\images"
os.chdir(fld)
fn = os.path.join(fld, "test.png")
ofn = os.path.join(fld, "test2.png")

img = cv2.imread(fn, 1)

# https://stackoverflow.com/questions/30506126/open-cv-error-215-scn-3-scn-4-in-function-cvtcolor

dst_gray, dst_color = cv2.pencilSketch(img, sigma_s=60, sigma_r=0.07, shade_factor=0.04) # shade_factor=0.05

cv2.imwrite(ofn, dst_gray)

stylize = cv2.stylization(img, sigma_s=60, sigma_r=0.07)

cv2.imwrite("style.png", stylize)
print("Done!")