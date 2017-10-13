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

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

# see http://cython.readthedocs.io/en/latest/src/tutorial/strings.html
# https://github.com/cython/cython/wiki/FAQ#how-do-i-pass-a-python-string-parameter-on-to-a-c-library

def _text_to_bytes(text):
    if isinstance(text, unicode): # most common case first
        utf8_data = text.encode('UTF-8')
    elif (PY_MAJOR_VERSION < 3) and isinstance(text, str):
        text.decode('ASCII') # trial decoding, or however you want to check for plain ASCII data
        utf8_data = text
    else:
        raise ValueError("Requires text input, got %s" % type(text))
    return utf8_data

# https://stackoverflow.com/questions/17511309/fast-string-array-cython

cdef char** to_cstring_array(list_str):

    cdef char **ret = <char **>PyMem_Malloc(len(list_str) * sizeof(char *))
    for i in range(len(list_str)):
        ret[i] = list_str[i]
    return ret

def _text_to_unicode(text):
    return text.decode('UTF-8')

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

def dumps(Map map):
    cdef ms.mapObj* _cmap
    tmp = map._get_mapObj()
    _cmap = tmp
    mapstring = ms.msWriteMapToString(_cmap)
    return _text_to_unicode(mapstring)

cdef _get_map(ms.mapObj* cmap):

    if cmap is NULL:               
        err = ms.msGetErrorObj()
        raise ValueError("{} (Error code {})".format(_text_to_unicode(err.message), err.code))

    return Map()._setup(cmap)

def convert_sld(sld):

    cdef ms.layerObj* layer
    layer = <ms.layerObj*> PyMem_Malloc(sizeof(ms.layerObj))
    ms.initLayer(layer, NULL)

    bsld = _text_to_bytes(sld)
    cdef const char *_sld = bsld

    cdef ms.CPLXMLNode* xml
    xml = ms.CPLParseXMLString(_sld)
    #success = ms.msSLDParseRule(xml, layer) # this is not a exported function so is not available
    l = Layer()
    l._setup(layer)
    return l

cdef class Layer:
    
    cdef ms.layerObj* _clayer

    def __cinit__(self):
        self._clayer = <ms.layerObj*> PyMem_Malloc(sizeof(ms.layerObj))
        ms.initLayer(self._clayer, NULL)

    cdef _setup(self, ms.layerObj* l):
        self._clayer = l
        return self

    def loads(self, snippet):
        """
        Load a layer from a Mapfile string
        Classes and styles not appearing
        Returns True on success
        """
        return bool(ms.msUpdateLayerFromString(self._clayer, _text_to_bytes(snippet), 0))

    @property
    def numclasses(self):
        return self._clayer.numclasses

    def __str__(self):
        return _text_to_unicode(ms.msWriteLayerToString(self._clayer))
        
    def __dealloc__(self):
        pass
        
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

    def __str__(self):
        return _text_to_unicode(ms.msWriteMapToString(self._cmap))        

    cdef public ms.mapObj* _get_mapObj(self):
        cdef ms.mapObj* cmap
        tmp = self._cmap
        cmap = tmp # set this or errors about "Storing unsafe C derivative of temporary Python reference""
        return cmap

    @property
    def name(self):
        # need to convert to a string for Python3
        return _text_to_unicode(self._cmap.name)

    def apply_sld(self, xml, layer_idx, layer_name):
        xml = _text_to_bytes(xml)
        status = ms.msSLDApplySLD(self._cmap, xml, layer_idx, layer_name, NULL)

        if status == 1:             
            err = ms.msGetErrorObj()
            raise ValueError("The request failed: {} (Error code {})".format(_text_to_unicode(err.message), err.code))


    #def get_layer_by_name(self, layer_name):
    #    
    #    m = self._cmap
    #    i = ms.msGetLayerIndex(m, name)
    #
    #    if i != -1:
    #      # MS_REFCNT_INCR(self->layers[i]); # from swiginc/map.i
    #      return (self.m.layers[i]) # return an existing layer
    #    else:
    #      return None


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

        http://mapserver.org/mapfile/outputformat.html
        If OUTPUTFORMAT sections declarations are not found in the map file, the following implicit declarations will be made. 
        Only those for which support is compiled in will actually be available. The GeoTIFF depends on building with GDAL support, 
        and the PDF and SVG depend on building with cairo support.

        PNG is first hence the default
        """
        cdef ms.outputFormatObj* format
        cdef ms.imageObj* img

        img = ms.msDrawMap(self._cmap, 0)        
        format = self._cmap.outputformat # TODO allow this to be set so geojson and png can both be used
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
        
    #def _process_template(self, func_name):
    #    """
    #    The 2 NULLs and a 0 are for values coming from a request object (param key, value, count)
    #    We can skip these if manipulating the Mapfile directly 
    #    """
    #    func = getattr(ms, func_name)
    #    try:
    #        html_string = func(self._cmap, 1, NULL, NULL, 0)
    #    except Exception as ex:
    #        logging.error(ex)
    #
    #    if html_string == NULL:
    #        raise Exception("There was a problem processing the template. Check for any references in the Map file.")
    #    else:
    #        return _text_to_unicode(html_string)

    def process_template(self):       
        """
        The 2 NULLs and a 0 are for values coming from a request object (param key, value, count)
        We can skip these if manipulating the Mapfile directly 
        """
        #return self._process_template("msProcessTemplate")
        try:
            html_string = ms.msProcessTemplate(self._cmap, 1, NULL, NULL, 0)
        except Exception as ex:
            logging.error(ex)

        if html_string == NULL:
            raise Exception("There was a problem processing the template. Check for any references in the Map file.")
        else:
            return _text_to_unicode(html_string)

    def process_query_template(self, params):
        """
        The 2 NULLs and a 0 are for values coming from a request object (param key, value, count)
        We can skip these if manipulating the Mapfile directly 
        """
        #return self._process_template("msProcessQueryTemplate")

        _keys = [_text_to_bytes(k) for k in params.keys()]
        _values = [_text_to_bytes(v) for v in params.values()]

        cdef char **keys = to_cstring_array(_keys)
        cdef char **values= to_cstring_array(_values)

        try:
            html_string = ms.msProcessQueryTemplate(self._cmap, 0, keys, values, len(params))
        except Exception as ex:
            logging.error(ex)

        if html_string == NULL:
            raise Exception("There was a problem processing the template. Check for any references in the Map file.")
        else:
            return _text_to_unicode(html_string)
        return self._process_template("msProcessQueryTemplate")


#    mapserv = msAllocMapServObj();
#    mapserv->sendheaders = sendheaders; /* override the default if necessary (via command line -nh switch) */
#
#    mapserv->request->NumParams = loadParams(mapserv->request, NULL, NULL, 0, NULL);
#    if( mapserv->request->NumParams == -1 ) {
#      msCGIWriteError(mapserv);
#      goto end_request;
#    }

# mapserv->map = msCGILoadMap(mapserv);

def load_map_from_params(params):

    cdef ms.cgiRequestObj* request
    request = ms.msAllocCgiObj()

    cdef ms.mapservObj* mapserv
    mapserv = ms.msAllocMapServObj()

    for idx, key in enumerate(params):
        val = params[key]

        k = _text_to_bytes(key)
        request.ParamNames[idx] = ms.msStrdup(k)

        v = _text_to_bytes(val)
        request.ParamValues[idx] = ms.msStrdup(v)

    for idx in range(0, len(params.items())):
        logging.debug("{} {}".format(request.ParamNames[idx], request.ParamValues[idx]))

    request.NumParams = len(params.items())
    logging.debug("Number of parameters sent: %i", request.NumParams)
    
    ms.msIO_installStdoutToBuffer()

    mapserv.request = request

    cdef ms.mapObj* map
    map = ms.msCGILoadMap(mapserv)

    if map is not NULL:
        mapserv.map = map
        status = ms.msCGIDispatchRequest(mapserv)
        check_status(status, params)
    else:
        raise Exception("There was a problem creating the Map object from the parameters")

    cdef char* _content_type # call msFree on this?

    _content_type = ms.msIO_stripStdoutBufferContentType()

    if _content_type is not NULL:
        ms.msIO_stripStdoutBufferContentHeaders()
    else:
        _content_type = ""

    content_type = _content_type # save to Python string
   
    result = ms.msIO_getStdoutBufferBytes()

    d = {
        "content_type": content_type,
        "data": result.data,
        "size": result.size
    }

    return d

def create_request(mapstring, params, force_ows_mode=1):

    mapstring = _text_to_bytes(mapstring)
    cdef ms.mapObj* map
    map = ms.msLoadMapFromString(mapstring, new_mappath="")
    cdef ms.cgiRequestObj *request

    # enum MS_REQUEST_TYPE {MS_GET_REQUEST, MS_POST_REQUEST};

    request = ms.msAllocCgiObj()

    # print(request.type) # MS_GET_REQUEST by default

    # use msStrdup to make a copy of the strings or the params are simply the last variable references 
    # https://stackoverflow.com/questions/38407896/converting-from-python-list-to-char-and-back-makes-all-elements-the-same-in-cy
    for idx, key in enumerate(params):
        val = params[key]

        k = _text_to_bytes(key)
        request.ParamNames[idx] = ms.msStrdup(k)

        v = _text_to_bytes(val)
        request.ParamValues[idx] = ms.msStrdup(v)

    for idx in range(0, len(params.items())):
        logging.debug("{} {}".format(request.ParamNames[idx], request.ParamValues[idx]))

    request.NumParams = len(params.items())
    logging.debug("Number of parameters sent: %i", request.NumParams)
    ms.msIO_installStdoutToBuffer()
    logging.debug("Buffer installed")

    # map dispatch 
    # https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/map.i#L485

    status = ms.msOWSDispatch(map, request, force_ows_mode)
    check_status(status, params)

    content_type = ms.msIO_stripStdoutBufferContentType()
    ms.msIO_stripStdoutBufferContentHeaders()
    result = ms.msIO_getStdoutBufferBytes()

    d = {
        "content_type": content_type,
        "data": result.data,
        "size": result.size
    }

    return d

def check_status(status, params):
    """
    TODO - if this fails it could be as OUTPUT format is missing, so check this
    Could also be as "gml_include_items" "all" is missing
    OWS Exception report not returned correctly
    """
    # MS_SUCCESS = 0, MS_FAILURE = 1, MS_DONE = 2 (not a valid request)
    logging.debug("Dispatch status: %i", status)

    if status == 1:             
        err = ms.msGetErrorObj()
        logging.warning(params)
        raise ValueError("The request failed: {} (Error code {})".format(_text_to_unicode(err.message), err.code))
    elif status == 2:
        logging.warning(params)
        raise ValueError("The request parameters are invalid")