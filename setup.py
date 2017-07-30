from setuptools import setup, Extension

try:
    from Cython.Distutils import build_ext
    from Cython.Build import cythonize
    USE_CYTHON = True
except:
    USE_CYTHON = False

ext_options = {
    'include_dirs': [r"D:\MapServer\release-1800-x64-dev\release-1800-x64\include"],
    'library_dirs': [r"D:\MapServer\release-1800-x64-dev\release-1800-x64\lib"],
    'libraries': ["mapserver"]
    }

file_ext = '.pyx' if USE_CYTHON else '.c'

exts = [Extension("mappyscript._mappyscript", ["mappyscript/_mappyscript" + file_ext], **ext_options)]

setup(
    name = "mappyscript",
    version = "0.0.1",
    url = "https://github.com/geographika/mappyscript",
    author = "Seth Girvin",
    license = "MIT",
    keywords = "mapserver mapscript mapfile mappyfile",
    ext_modules=cythonize(exts) if USE_CYTHON else exts,
    cmdclass={'build_ext': build_ext} if USE_CYTHON else {}
)