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
from cpython.version cimport PY_MAJOR_VERSION

# see http://cython.readthedocs.io/en/latest/src/tutorial/strings.html
# https://github.com/cython/cython/wiki/FAQ#how-do-i-pass-a-python-string-parameter-on-to-a-c-library

def _text_to_bytes(text):
    if isinstance(text, unicode): # most common case first
        utf8_data = text.encode('UTF-8')
    elif (PY_MAJOR_VERSION < 3) and isinstance(text, str):
        text.decode('ASCII') # trial decoding, or however you want to check for plain ASCII data
        utf8_data = text
    else:
        raise ValueError("requires text input, got %s" % type(text))
    return utf8_data

def version():
    return ms.msGetVersion()

def version_number():
    return ms.msGetVersionInt()

def load(fn):
    fn = _text_to_bytes(fn)
    cdef ms.mapObj* _cmap
    _cmap = ms.msLoadMap(fn, new_mappath="")
    return _get_map(_cmap)

def loads(mapstring):
    mapstring = _text_to_bytes(mapstring)
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
        # need to convert to a string for Python3
        return self._cmap.name.decode('utf-8')

    @property
    def SLD(self):
        return ms.msSLDGenerateSLD(self._cmap, -1, NULL)

    def draw(self, output_file):
        output_file = _text_to_bytes(output_file)
        cdef ms.imageObj* img

        img = ms.msDrawMap(self._cmap, 0)
        ms.msSaveImage(self._cmap, img, output_file)

        ms.msFreeImage(img)    

    def draw_buffer(self):
        """
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
        logging.debug("Image buffer size: %i", img_size)
        ms.msFreeImage(img) 
        py_string = img_buffer[:img_size]
        return py_string

    def draw_legend(self, output_file):

        output_file = _text_to_bytes(output_file)
        cdef ms.imageObj* img

        img = ms.msDrawLegend(self._cmap, 0, NULL)
        ms.msSaveImage(self._cmap, img, output_file)
        ms.msFreeImage(img)   
        
def create_request(mapstring, params):

    mapstring = _text_to_bytes(mapstring)
    cdef ms.mapObj* map
    map = ms.msLoadMapFromString(mapstring, new_mappath="")
    cdef ms.cgiRequestObj *request

    # enum MS_REQUEST_TYPE {MS_GET_REQUEST, MS_POST_REQUEST};

    request = ms.msAllocCgiObj()

    # print(request.type) # MS_GET_REQUEST by default

    for idx, key in enumerate(params): 
        request.ParamNames[idx] = _text_to_bytes(key)
        request.ParamValues[idx] = _text_to_bytes(params[key])

    request.NumParams = len(params.items())

    ms.msIO_installStdoutToBuffer()
    
    # map dispatch 
    # https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/map.i#L485

    force_ows_mode = 1
    success = ms.msOWSDispatch(map, request, force_ows_mode)

    if success != 0:             
        err = ms.msGetErrorObj()
        raise ValueError("The request failed: {} (Error code {})".format(err.message, err.code))

    content_type = ms.msIO_stripStdoutBufferContentType()
    ms.msIO_stripStdoutBufferContentHeaders()
    result = ms.msIO_getStdoutBufferBytes()

    d = {
        "content_type": content_type,
        "data": result.data,
        "size": result.size
    }

    return result