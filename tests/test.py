import os
import logging
import pytest
import json
from io import open

import xml.dom.minidom

try:
    import urllib.parse as urlparse # Python3
except ImportError as ex:
    import urlparse

def get_params_from_url(url):
    print(urlparse.urlsplit(url))
    # SplitResult(scheme='http', netloc='www.example.org', path='/default.html', query='ct=32&op=92&item=98', fragment='')
    # urlparse.parse_qs(urlparse.urlsplit(url).query)
    return dict(urlparse.parse_qsl(urlparse.urlsplit(url).query))

try:
    import mappyscript as ms
except ImportError as ex:
    #DLL_LOCATION = r"C:\MapServer\bin" # works
    #DLL_LOCATION = r"D:\MapServer\release-1500-x64-gdal-mapserver\bin" # fails
    DLL_LOCATION = r"D:\MapServer\release-1800-x64-dev\release-1800-x64\bin" # works
    os.environ['PATH'] = DLL_LOCATION + ';' + os.environ['PATH']
    import mappyscript as ms

def test_version():
    v = ms.version()
    assert("MapServer" in v)

def test_version():
    v = ms.version_number()
    assert(int(v) > 0)

def test_map_from_string():

    s = """
MAP
    NAME "Test"
    EXTENT -100 -100 100 100
    SIZE 400 400
    LAYER
        STATUS ON
        NAME "TestLayer"
        TYPE POLYGON
        FEATURE
            POINTS
                1 1
                50 50
                1 50
                1 1
            END
        END
        CLASS
            STYLE
                COLOR 0 0 255
                OUTLINECOLOR 2 2 2
            END
        END
    END
END
    """

    m = ms.loads(s)
    ns = ms.dumps(m)
    print(ns)


    m.draw("test1.png")

    with open("test2.png", "wb") as f:
        f.write(m.draw_buffer())

def test_map_from_file():
    fn = os.path.join(os.path.dirname(__file__), "test.map")
    m = ms.load(fn)
    assert(m.name == "Test")
    m.draw("test3.png")

    with open("test4.png", "wb") as f:
        f.write(m.draw_buffer())

def get_ows_map():
    """
    cd /D D:\MapServer\release-1800-x64-gdal-mapserver
    SDKShell.bat
    mapserv "QUERY_STRING=map=D:\Temp\ows_test.map&SERVICE=WMS&VERSION=1.1.0&REQUEST=GetCapabilities" -nh
    """

    s = """
MAP
    NAME "Test"
    EXTENT -100 -100 100 100
    SIZE 400 400
    WEB
      METADATA
        "wms_title" "OWS Test"
        "ows_enable_request" "*"
		"ows_onlineresource" "https://localhost/mapserver/"	
      END
    END
    LAYER
        STATUS ON
        NAME "TestLayer"
        TYPE POLYGON
        FEATURE
            POINTS
                1 1
                50 50
                1 50
                1 1
            END
        END
        CLASS
            STYLE
                COLOR 0 0 255
                OUTLINECOLOR 2 2 2
            END
        END
    END
END
    """
    return s

def test_getcapabilities_request():

    params = {
              "SERVICE": "WMS",
              "VERSION": "1.1.0",
              "REQUEST": "GetCapabilities"
              }

    s = get_ows_map()
    result = ms.create_request(s, params)
    xml_ = xml.dom.minidom.parseString(result["data"])
    print(xml_.toprettyxml(indent="  ", newl=""))

def test_wfs_get_request():
    """
    cd /D D:\MapServer\release-1800-x64-gdal-mapserver
    SDKShell.bat
    mapserv "QUERY_STRING=map=D:\GitHub\mappyscript\tests\test_ows.map&service=WFS&REQUEST=GetFeature&VERSION=1.1.0&TYPENAME=TestLayer&MAXFEATURES=10&srsName=EPSG:4326" -nh   
    """
    fn = os.path.join(os.path.dirname(__file__), "test_ows.map")

    # following is required if any paths are relative (e.g. PROJECTION lib)
    os.chdir(os.path.dirname(fn))

    params = {
    "SERVICE": "WFS",
    "REQUEST": "GetFeature",
    "VERSION": "1.1.0",
    "TYPENAME": "TestLayer",
    #"BBOX": "0,0,100,100",
    "MAXFEATURES": "1",
    "OUTPUTFORMAT": "geojson",
    #"SRSNAME": "EPSG:4326"
    }

    #url = "http://example.com/wfs?service=WFS&version=1.0.0&REQUEST=GetCapabilities"
    #params = get_params_from_url(url)

    #params = {
    #    "service": "WFS",
    #    "version": "1.0.0",
    #    "REQUEST": "GetCapabilities"
    #}


    print(json.dumps(params, indent=4))
    qs = '&'.join(['{}={}'.format(k,v) for k,v in params.items()])
    print(qs)

    with open(fn, "r", encoding="utf-8") as f:
        s = f.read()

    result = ms.create_request(s, params)
    ct = result["content_type"]
    data = result["data"].decode('utf-8')

    if ct == b'text/xml; subtype=gml/3.1.1; charset=UTF-8':
        xml_ = xml.dom.minidom.parseString(data)
        print(xml_.toprettyxml(indent="  ", newl=""))
    elif ct == b'application/json; subtype=geojson':
        data = json.loads(data)
        print(json.dumps(data, indent=4))       
    else:
        print(ct)


def test_wfs_filter():
    """
    http://mapserver.org/ogc/filter_encoding.html#filter-encoding
    """

    filter = """
<Filter>
<PropertyIsEqualTo>
    <PropertyName>FID</PropertyName>
    <Literal>067041003</Literal>
</PropertyIsEqualTo>
</Filter>"""

    fn = os.path.join(os.path.dirname(__file__), "test_ows.map")

    # following is required if any paths are relative (e.g. PROJECTION lib)
    os.chdir(os.path.dirname(fn))

    params = {
    "SERVICE": "WFS",
    "REQUEST": "GetFeature",
    "VERSION": "1.1.0",
    "TYPENAME": "TestLayer",
    "FILTER": filter,
    "MAXFEATURES": "1",
    "OUTPUTFORMAT": "geojson",
    #"SRSNAME": "EPSG:4326"
    }

    with open(fn, "r", encoding="utf-8") as f:
        s = f.read()

    result = ms.create_request(s, params)
    ct = result["content_type"]
    data = result["data"].decode('utf-8')

    if ct == b'text/xml; subtype=gml/3.1.1; charset=UTF-8':
        xml_ = xml.dom.minidom.parseString(data)
        print(xml_.toprettyxml(indent="  ", newl=""))
    elif ct == b'application/json; subtype=geojson':
        data = json.loads(data)
        print(json.dumps(data, indent=4))       
    else:
        print(ct)


def test_legend():
    """
    Only CLASSES with NAME properties will appear
    """
    fn = os.path.join(os.path.dirname(__file__), "test.map")
    m = ms.load(fn)
    #m.draw("mymap.png")
    m.draw_legend("legend.png")


def test_load_map_from_params():
    """
    cd /D D:\MapServer\release-1800-x64-gdal-mapserver
    SDKShell.bat
    mapserv "QUERY_STRING=map=D:\GitHub\mappyscript\tests\test_template.map&mode=COORDINATE&IMGEXT=-100 -100 100 100&IMGXY=10 10" -nh


    D:\MapServer\release-1800-x64-gdal-mapserver>    mapserv "QUERY_STRING=map=D:\GitHub\mappyscript\tests\test_template.map&mode=COORDINATE&IMGEXT=-100 -100 100 100&IMGXY=10 10" -nh
    Your "<i>click</i>" corresponds to (approximately): (-94.9875, 94.9875).
    D:\MapServer\release-1800-x64-gdal-mapserver>
    """
    params = {
        "mode": "COORDINATE", # "BROWSE", # "LEGEND", # see https://github.com/mapserver/mapserver/blob/master/maptemplate.h
        "MAP": r"D:\GitHub\mappyscript\tests\test_template.map",
        "IMGEXT": "-100 -100 100 100",
        "IMGXY": "10 10"
    }

    # https://github.com/mapserver/mapserver/blob/master/mapservutil.c#L1187 - coordinate mode
    result = ms.load_map_from_params(params)

    ct = result["content_type"]
    print(ct)
    data = result["data"].decode('utf-8')

    if ct == b'text/xml; subtype=gml/3.1.1; charset=UTF-8':
        xml_ = xml.dom.minidom.parseString(data)
        print(xml_.toprettyxml(indent="  ", newl=""))
    elif ct == b'application/json; subtype=geojson':
        data = json.loads(data)
        print(json.dumps(data, indent=4))       
    elif ct == b'text/html':
        print(data)
    elif ct == b'image/png':
        data = result["data"]
        # not working..
        with open("params.png", "wb") as f:
            f.write(data)
    else:
        print(data)

def run_tests():  

    pytest.main(["tests/test.py"])

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    #test_getcapabilities_request()
    #test_load_map_from_params()
    #run_tests()
    test_map_from_string()
    #test_map_from_string()
    #test_legend()
    print("Done!")