"""
http://mapserver.org/mapscript/imagery.html

test_map = MapScript.mapObj('tests/test.map')
map_image = test_map.draw()
processTemplate
queryByFeatures

map.save()

# cdef can only be called by Cython code
# def can only be used to return and accept Python objects

https://github.com/mapserver/mapserver/blob/66309eebb7ba0dc70469efeb40f865a8e88fafbd/mapscript/csharp/examples/getbytes.cs
"""
import logging
cimport mapserver as ms

def version():
    return ms.msGetVersion()

def version_number():
    return ms.msGetVersionInt()

def load(fn):

    cdef ms.mapObj* _cmap
    _cmap = ms.msLoadMap(fn, new_mappath="")
    return _get_map(_cmap)

def loads(mapstring):

    cdef ms.mapObj* map
    map = ms.msLoadMapFromString(mapstring, new_mappath="")
    return _get_map(map)

cdef _get_map(ms.mapObj* cmap):

    if cmap is NULL:               
        err = ms.msGetErrorObj()
        raise ValueError("{} (Error code {})".format(err.message, err.code))

    return Map()._setup(cmap)

cdef class Map:
    cdef ms.mapObj* _cmap

    def __cinit__(self):
        self._cmap = ms.msNewMapObj()

    def __dealloc__(self):
        if self._cmap is not NULL:
            ms.msFreeMap(self._cmap)

    cdef _setup(self, ms.mapObj* m):
        self._cmap = m
        return self

    @property
    def name(self):
        return self._cmap.name

    @property
    def SLD(self):
        return ms.msSLDGenerateSLD(self._cmap, -1, NULL)

    def draw(self, output_file):
        cdef ms.imageObj* img

        img = ms.msDrawMap(self._cmap, 0)
        ms.msSaveImage(self._cmap, img, output_file)

        ms.msFreeImage(img)    

    def draw_buffer(self):
        """
        TODO implementation below not working
        See mapserver/mapscript/python/pyextend.i for equivalent in MapScript
        """
        cdef ms.outputFormatObj* format
        cdef ms.imageObj* img

        img = ms.msDrawMap(self._cmap, 0)        
        format = self._cmap.outputformat
        #print(format.name)  # png
        
        cdef unsigned char *img_buffer = NULL
        cdef int img_size
        
        img_buffer = ms.msSaveImageBuffer(img, &img_size, format)   
        #ms.msFreeImage(img) 
        py_string = img_buffer
        return py_string