import os
import logging
import pytest
try:
    import mappyscript as ms
except ImportError as ex:
    #DLL_LOCATION = r"C:\MapServer\bin" # works
    #DLL_LOCATION = r"D:\MapServer\release-1500-x64-gdal-mapserver\bin" # fails
    DLL_LOCATION = r"D:\MapServer\release-1800-x64-gdal-mapserver\bin" # works
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
    assert(m.name == "Test")
    assert(len(m.SLD) > 0)

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

def test_request():
    qs = "KEY1=VAL1&KEY2=VAL2"

    params = {
              "SERVICE": "WMS",
              "VERSION": "1.1.0",
              "REQUEST": "GetCapabilities"
              }

    s = get_ows_map()
    result = ms.create_request(s, params)
    print(result["data"])

def test_legend():
    """
    Only CLASSES with NAME properties will appear
    """
    fn = os.path.join(os.path.dirname(__file__), "test.map")
    #os.chdir(r"C:\MapServer\apps\nta")
    #fn = r"C:\MapServer\apps\nta\nta.map"
    m = ms.load(fn)
    #m.draw("mymap.png")
    m.draw_legend("legend.png")


def run_tests():  

    pytest.main(["tests/test.py"])

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)


    #run_tests()
    #test_map_from_string()
    test_request()
    #test_legend()
    print("Done!")