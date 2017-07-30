from setuptools import setup, Extension
from Cython.Build import cythonize

ext_options = {
    'include_dirs': [r"D:\MapServer\release-1800-x64-dev\release-1800-x64\include"],
    'library_dirs': [r"D:\MapServer\release-1800-x64-dev\release-1800-x64\lib"],
    'libraries': ["mapserver"]
    }

ext = Extension("mappyscript._mappyscript", ["mappyscript/_mappyscript.pyx"], **ext_options)

setup(
    name = "mappyscript",
    version = "0.0.1",
    url = "https://github.com/geographika/mappyscript",
    author = "Seth Girvin",
    license = "MIT",
    keywords = "mapserver mapscript mapfile mappyfile",
    ext_modules = cythonize([ext])
)