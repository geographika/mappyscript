cdef extern from "src/maperror.h":

    # functions to return MapServer versions
    int msGetVersionInt()
    char *msGetVersion()

    # the MapServer error object
    cdef struct errorObj:
        int code
        char *message

    errorObj* msGetErrorObj()

cdef extern from "src/mapserver.h":

    # declare the required MapServer objects

    # note outputFormatObj is typedef struct in mapserver.h
    ctypedef struct outputFormatObj:
        char *name

    # note mapObj is struct mapObj in mapserver.h
    cdef struct mapObj:
        char *name
        outputFormatObj* outputformat

    cdef struct imageObj:
        char *imagepath
        char *imageurl


    mapObj* msNewMapObj()
    void msFreeMap(mapObj* map)

    mapObj* msLoadMapFromString(char* buffer, char* new_mappath)
    mapObj* msLoadMap(char* filename, char* new_mappath)

    # image creation functions
    # MS_DLL_EXPORT imageObj *msDrawMap(mapObj *map, int querymap);
    imageObj* msDrawMap(mapObj* map, int querymap)

    imageObj* msImageCreate()
    void msFreeImage(imageObj* img)    
    int msSaveImage(mapObj* map, imageObj* img, char* filename)

    # MS_DLL_EXPORT unsigned char *msSaveImageBuffer(imageObj* image, int *size_ptr, outputFormatObj *format);
    unsigned char* msSaveImageBuffer(imageObj *image, int* size_ptr, outputFormatObj* format)

cdef extern from "src/mapogcsld.h":

    # for generating SLD
    char* msSLDGenerateSLD(mapObj* map, int iLayer, const char *pszVersion)


## for OGC services - see mapserver/mapscript/mapscript.i
#ctypedef struct gdBuffer:
#    unsigned char *data
#    int size
#    int owns_data
#
## http://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html#styles-of-struct-union-and-enum-declaration
#
#from libc.stdio cimport FILE
#
#cdef extern from "src/mapio.h":
#
#    ctypedef struct msIO_llReadWriteFunc:
#        void *cbData
#        void *data
#        int byteCount
#
#    cdef struct msIOContext_t:
#        const char *label
#        int write_channel # 1 for stdout/stderr, 0 for stdin
#        msIO_llReadWriteFunc readWriteFunc
#        void *cbData
#
#    ctypedef msIOContext_t msIOContext
#
#    ctypedef struct msIOBuffer:
#        unsigned char *data
#        int data_len # really buffer length
#        int data_offset # really buffer used
#
#    msIOContext *msIO_getHandler( FILE * )


