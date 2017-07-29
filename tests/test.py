import os

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
            NAME 'blah'
            DEBUG on
            STATUS on # need to enforce lowercase
            EXTENT -100 -100 100 100
            SIZE 400 400
            LAYER
                STATUS ON
                NAME "hi"
                TYPE polygon
                FEATURE
                  POINTS 1 1 50 50 1 50 1 1 END
                END
                CLASS
                    STYLE
                        COLOR 0 255 0
                        OUTLINECOLOR 2 2 2
                    END
                END

            END
        END
    """

    m = ms.loads(s)
    print m.name
    #print m.SLD
    fn = r"D:\temp\test1.png"
    m.draw(fn)
    fn = r"D:\temp\test5.png"

    with open(fn, "wb") as f:
        f.write(m.draw_buffer())

os.chdir(r"C:\MapServer\apps\foss4ge")
m = ms.load(r"mapfile.map")
print m.name
fn = r"D:\temp\test2.png"
m.draw(fn)

fn = r"D:\temp\test3.png"

with open(fn, "wb") as f:
    f.write(m.draw_buffer())

print("Done!")