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
from libc.stdio cimport FILE

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

        
#def _msIO_getStdoutBufferBytes():
#   """
#   See mapscript/swiginc/msio.i
#   For FILE example see http://cython.readthedocs.io/en/latest/src/userguide/language_basics.html#checking-return-values-of-non-cython-functions
#   There is no -> operator in Cython. Instead of p->x, use p.x
#   """
#
#   #cdef FILE *ptr_fr
#   #ms.msIOContext *ctx = ms.msIO_getHandler( (FILE *) "stdout" )
#   cdef ms.msIOContext *ctx = ms.msIO_getHandler(<FILE>"stdout")
#   cdef ms.msIOBuffer *buf
#   cdef ms.gdBuffer gdBuf
#
#   # if ( ctx == NULL || ctx->write_channel == MS_FALSE || strcmp(ctx->label,"buffer") != 0 ):
#   #if ( ctx == NULL || ctx->write_channel == False || strcmp(ctx->label,"buffer") != 0 ):
#	#    #msSetError( MS_MISCERR, "Can't identify msIO buffer.",
#   #    #                "msIO_getStdoutBufferString" );
#	#    #gdBuf.data = (unsigned char*)"";
#	#    #gdBuf.size = 0;
#	#    #gdBuf.owns_data = MS_FALSE;
#	#    #return gdBuf;
#   #    return NULL
#
#   #buf = (ms.msIOBuffer *) ctx.cbData #typecast
#   buf = <ms.msIOBuffer>ctx.cbData # Type casts are written <type>value http://cython.readthedocs.io/en/latest/src/userguide/language_basics.html#differences-between-c-and-cython-expressions
#
#   gdBuf.data = buf.data
#   gdBuf.size = buf.data_offset
#   gdBuf.owns_data = True # MS_TRUE
#
#   # we are seizing ownership of the buffer contents
#   buf.data_offset = 0;
#   buf.data_len = 0;
#   buf.data = NULL;
#
#   return gdBuf;

