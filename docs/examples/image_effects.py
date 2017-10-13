import os
import mappyfile
from PIL import Image
from PIL import ImageFilter
from io import BytesIO
import logging

"""
As soon as the following is added images are no longer generated

    OUTPUTFORMAT
        NAME "geojson"
        DRIVER "OGR/GEOJSON"
        MIMETYPE "application/json; subtype=geojson"
        FORMATOPTION "STORAGE=stream"
    END

Then have to add:

	OUTPUTFORMAT
	  NAME "png"
	  DRIVER AGG/PNG
	  MIMETYPE "image/png"
	  IMAGEMODE RGB
	  EXTENSION "png"
	  FORMATOPTION "GAMMA=0.75"
	END	

Before?

See https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/map.i#L188 for getting and setting these
"""
try:
    import mappyscript as ms
except ImportError as ex:
    DLL_LOCATION = r"D:\MapServer\release-1800-x64-gdal-mapserver\bin" # works
    os.environ['PATH'] = DLL_LOCATION + ';' + os.environ['PATH']
    import mappyscript as ms

def to_mapobj(m):
    s = mappyfile.dumps(m)
    return ms.loads(s)

def change_layers_status(m, status="OFF"):
    # turn all layers off

    for l in m["layers"]:
        l["status"] = status

def main(fn):
    
    os.chdir(os.path.dirname(fn))
    m = mappyfile.load(fn)
    m["extent"] = [-1216936, 6651632, -527026, 7508366]
    change_layers_status(m, "ON")

    mo = to_mapobj(m)
    #mo.draw("mymap.png")

    temp_buff = BytesIO()
    temp_buff.write(mo.draw_buffer())
    temp_buff.seek(0) #need to jump back to the beginning before handing it off to PIL
    
    im = Image.open(temp_buff)

    im1 = im.filter(ImageFilter.EMBOSS)
    im1.save("mymap_blur.png")

logging.basicConfig(level=logging.DEBUG)
fn = r"C:\MapServer\apps\example\my.map"
main(fn)
print("Done!")



