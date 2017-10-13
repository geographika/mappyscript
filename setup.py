from setuptools import setup, Extension, Distribution

## https://stackoverflow.com/a/39640762/179520
#class BinaryDistribution(Distribution):
#    def is_pure(self):
#        return False
try:
    #from Cython.Distutils import build_ext
    from Cython.Build import cythonize
    USE_CYTHON = True
except:
    USE_CYTHON = False

ext_options = {
    # D:\MapServer\release-1800-x64-dev\release-1800-x64\bin"
    'include_dirs': [r"D:\MapServer\release-1800-x64-dev\release-1800-x64\include"],
    'library_dirs': [r"D:\MapServer\release-1800-x64-dev\release-1800-x64\lib"],
    'libraries': ["mapserver","gdal_i"] #"gdal_i"] # filename is gdal_i.lib, include this or "_mappyscript.obj : error LNK2001: unresolved external symbol CPLParseXMLString"
    }

file_ext = '.pyx' if USE_CYTHON else '.c'
exts = [Extension("mappyscript._mappyscript", ["mappyscript/_mappyscript" + file_ext], **ext_options)]

setup(
    name = "mappyscript",
    version = "0.0.3",
    url = "https://github.com/geographika/mappyscript",
    author = "Seth Girvin",
    license = "MIT",
    keywords = "mapserver mapscript mapfile mappyfile",
    ext_modules=cythonize(exts) if USE_CYTHON else exts,
    #cmdclass={'build_ext': build_ext} if USE_CYTHON else {},
    packages=["mappyscript"],
    include_package_data=True,
    #distclass=BinaryDistribution
)