import os
import logging
import pytest

#DLL_LOCATION = r"C:\MapServer\bin"
DLL_LOCATION = r"D:\MapServer\release-1500-x64-gdal-mapserver\bin" # fails
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
                COLOR 255 0 0
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

def run_tests():        
    pytest.main(["tests/test.py"])

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    run_tests()
    print("Done!")