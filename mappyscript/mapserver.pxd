cdef extern from "maperror.h":

    # functions to return MapServer versions
    int msGetVersionInt()
    char *msGetVersion()

    # the MapServer error object
    cdef struct errorObj:
        int code
        char *message

    errorObj* msGetErrorObj()

cdef extern from "cpl_minixml.h":

    ctypedef enum CPLXMLNodeType:
        pass

    ctypedef struct CPLXMLNode:
        char pszValue

    CPLXMLNode *CPLParseXMLString(const char* xml)

cdef extern from "mapserver.h":

    # declare the required MapServer objects

    char* msStrdup(const char * pszString)

    # note outputFormatObj is typedef struct in mapserver.h
    ctypedef struct outputFormatObj:
        char *name

    # note mapObj is struct mapObj in mapserver.h
    cdef struct mapObj:
        char *name
        outputFormatObj* outputformat

    cdef struct layerObj:
        char *name
        int numclasses

    int initLayer(layerObj *layer, mapObj *map)
 
    int msLayerGetNumFeatures(layerObj *layer)

    cdef struct imageObj:
        char *imagepath
        char *imageurl

    mapObj *msCGILoadMap(mapservObj *mapserv)

    mapObj* msNewMapObj()
    void msFreeMap(mapObj* map)

    mapObj* msLoadMapFromString(char* buffer, char* new_mappath)
    mapObj* msLoadMap(char* filename, char* new_mappath)

    int msGetLayerIndex(mapObj *map, const char *name)

    char *msWriteMapToString(mapObj* map)

    char *msWriteLayerToString(layerObj *layer)
    int msUpdateLayerFromString(layerObj *layer, char *string, int url_string)

    # image creation functions
    # MS_DLL_EXPORT imageObj *msDrawMap(mapObj *map, int querymap);
    imageObj* msDrawMap(mapObj* map, int querymap)

    imageObj* msImageCreate()
    void msFreeImage(imageObj* img)    
    int msSaveImage(mapObj* map, imageObj* img, char* filename)

    # MS_DLL_EXPORT unsigned char *msSaveImageBuffer(imageObj* image, int *size_ptr, outputFormatObj *format);
    unsigned char* msSaveImageBuffer(imageObj *image, int* size_ptr, outputFormatObj* format)

    # MS_DLL_EXPORT imageObj WARN_UNUSED *msDrawLegend(mapObj *map, int scale_independent, map_hittest *hittest)
    imageObj* msDrawLegend(mapObj* map, int scale_independent, void *hittest)
    
cdef extern from "mapserv.h":

    int msCGIDispatchRequest(mapservObj *mapserv)

cdef extern from "mapogcsld.h":

    # following 2 functions are both private
    #int msSLDParseRule(CPLXMLNode *psRoot, layerObj *psLayer)
    #layerObj  *msSLDParseSLD(mapObj *map, char *psSLDXML, int *pnLayers)

    # for generating and applying SLD
    char* msSLDGenerateSLD(mapObj* map, int iLayer, const char *pszVersion)

    int msSLDApplySLD(mapObj *map, char *psSLDXML, int iLayer, char *pszStyleLayerName, char **ppszLayerNames)   



cdef extern from "mapio.h":

    # void MS_DLL_EXPORT msIO_installStdoutToBuffer(void);
    void msIO_installStdoutToBuffer()
    char* msIO_stripStdoutBufferContentType()
    void msIO_stripStdoutBufferContentHeaders()


# https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/owsrequest.i
# https://github.com/mapserver/mapserver/blob/branch-7-0/cgiutil.h

cdef extern from "cgiutil.h":

    # http://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html#struct-union-enum-styles

    ctypedef enum MS_REQUEST_TYPE:
        MS_GET_REQUEST = 0
        MS_POST_REQUEST = 1

    ctypedef struct cgiRequestObj:
        char **ParamNames
        char **ParamValues
        int NumParams
        int type # MS_REQUEST_TYPE
        char *contenttype
        char *postrequest
        char *httpcookiedata

    # MS_DLL_EXPORT cgiRequestObj *msAllocCgiObj(void);
    cgiRequestObj* msAllocCgiObj()

    # ms_uint32 raw_post_data_length

    #int loadParams(cgiRequestObj *request, char* (*getenv2)(const char*, void* thread_context),
    #                         char *raw_post_data, ms_uint32 raw_post_data_length, void* thread_context)

    int loadParams(cgiRequestObj *request, NULL, NULL, NULL, NULL)

cdef extern from "mapows.h":
    # https://github.com/mapserver/mapserver/blob/branch-7-0/mapows.h
    # For OGC services - see mapserver/mapscript/mapscript.i
    # https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/msio.i
    
    # MS_DLL_EXPORT int msOWSDispatch(mapObj *map, cgiRequestObj *request, int ows_mode);
    int msOWSDispatch(mapObj* map, cgiRequestObj* request, int ows_mode)

cdef extern from "maptemplate.h":
    # https://github.com/mapserver/mapserver/blob/branch-7-0/maptemplate.h
    # https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/map.i#L450   

    #char *msProcessTemplate(mapObj *map, int bGenerateImages, char **names, char **values, int numentries);    
    char* msProcessTemplate(mapObj *map, int bGenerateImages, char **names, char **values, int numentries)

    char* msProcessQueryTemplate(mapObj *map, int bGenerateImages, char **names, char **values, int numentries)

    ctypedef struct mapservObj:
        mapObj* map  
        cgiRequestObj* request

    mapservObj* msAllocMapServObj()

    void msFreeMapServObj(mapservObj* mapserv)

    
ctypedef struct gdBuffer:
    unsigned char *data
    int size
    int owns_data

from libc.stdio cimport FILE

cdef extern from "mapio.h":
    # https://github.com/mapserver/mapserver/blob/branch-7-0/mapio.h
    # http://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html#styles-of-struct-union-and-enum-declaration
    # https://stackoverflow.com/questions/3674200/what-does-a-typedef-with-parenthesis-like-typedef-int-fvoid-mean-is-it-a
    # msIO_llReadWriteFunc is a callback function
    # Example at https://www.safaribooksonline.com/library/view/learning-cython-programming/9781783280797/ch02s04.html

    ctypedef int (*msIO_llReadWriteFunc) ( void *cbData, void *data, int byteCount )

    #  write_channel # 1 for stdout/stderr, 0 for stdin
    ctypedef struct msIOContext:
        const char *label
        int write_channel
        msIO_llReadWriteFunc readWriteFunc
        void *cbData

    ctypedef struct msIOBuffer:
        unsigned char *data
        int data_len # really buffer length
        int data_offset # really buffer used

    # msIOContext MS_DLL_EXPORT *msIO_getHandler( FILE * );

    msIOContext* msIO_getHandler(FILE*)

cdef inline gdBuffer msIO_getStdoutBufferBytes():
    # See mapscript/swiginc/msio.i
    # Also https://github.com/mapserver/mapserver/blob/branch-7-0/mapio.c
    # For FILE example see http://cython.readthedocs.io/en/latest/src/userguide/language_basics.html#checking-return-values-of-non-cython-functions
    # There is no -> operator in Cython. Instead of p->x, use p.x   

    # msIO_getHandler checks for strings e.g. "stdout"
    cdef char* c_string = "stdout"
    cdef msIOContext *ctx = msIO_getHandler(<FILE *> c_string)
    cdef msIOBuffer *buf
    cdef gdBuffer gdBuf

    gdBuf.data = <unsigned char *> ""
    gdBuf.size = 0
    gdBuf.owns_data = 0

    if ctx == NULL or ctx.write_channel == False: # or ctx.label == b"buffer":
        # Can't identify msIO buffer
        return gdBuf
    else:
        label = ctx.label
        if label != b"buffer":
            return gdBuf

    buf = <msIOBuffer *> ctx.cbData # Type casts are written <type>value http://cython.readthedocs.io/en/latest/src/userguide/language_basics.html#differences-between-c-and-cython-expressions
    gdBuf.data = buf.data
    gdBuf.size = buf.data_offset
    gdBuf.owns_data = True # MS_TRUE

    # we are seizing ownership of the buffer contents
    buf.data_offset = 0
    buf.data_len = 0
    buf.data = NULL

    return gdBuf
