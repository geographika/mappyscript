"""
SLD plan

Components

- SLD / XML code editor
- Mapfile code editor output
- Sample map with features


XSD on SLD?
http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd
https://pypi.python.org/pypi/xmlschema
"""
import os
import logging
import pytest
import json
from io import open

import xml.dom.minidom

try:
    import mappyscript as ms
except ImportError as ex:
    DLL_LOCATION = r"D:\MapServer\release-1800-x64-gdal-mapserver\bin" # works

    DLL_LOCATION = r"D:\MapServer\release-1800-x64-dev\release-1800-x64\bin"  # depends on GDAL201.DLL (not GDAL202.DLL) or get cannot load DLL
    os.environ['PATH'] = DLL_LOCATION + ';' + os.environ['PATH']
    import mappyscript as ms

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
    assert(m.name == "Test")
    assert(len(m.SLD) > 0)

    xml_ = xml.dom.minidom.parseString(m.SLD)
    print(xml_.toprettyxml(indent="  ", newl=""))

def test_dumps():

    m = ms.loads("MAP LAYER NAME 'TestLayer' TYPE LINE END END")
    #print(str(m))   


    fn = os.path.join(os.path.dirname(__file__), "test_sites.sld")

    with open(fn) as f:
        sld = f.read()

    sld = """
        <?xml version="1.0" ?><StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">  
          <NamedLayer>    
            <Name>TestLayer</Name>    
            <UserStyle>      
               <FeatureTypeStyle>
                 <Rule>
                   <PolygonSymbolizer>
                     <Fill>
                       <CssParameter name="fill">#40FF40</CssParameter>
                     </Fill>
                     <Stroke>
                       <CssParameter name="stroke">#FFFFFF</CssParameter>
                       <CssParameter name="stroke-width">2</CssParameter>
                     </Stroke>
                   </PolygonSymbolizer>
                   <TextSymbolizer>
                     <Label>
                       <ogc:PropertyName>name</ogc:PropertyName>
                     </Label>
                     <Halo>
                       <Radius>3</Radius>
                       <Fill>
                         <CssParameter name="fill">#FFFFFF</CssParameter>
                       </Fill>
                     </Halo>
                   </TextSymbolizer>
                 </Rule>
               </FeatureTypeStyle>      
            </UserStyle>    
          </NamedLayer>  
        </StyledLayerDescriptor>
    """
    xmldoc = xml.dom.minidom.parseString(sld.strip())
    named_layers = xmldoc.getElementsByTagName('NamedLayer')[0]
    print(named_layers)
    #second_items = xmldoc.getElementsByTagName("secondSetOfItems")[0]
    names = named_layers.getElementsByTagName("Name")
    for n in names:
        print(dir(n))

    #print(xmldoc.toprettyxml(indent="  ", newl=""))
    
    layer_idx = 0
    layer_name = b"TestLayer"

    m.apply_sld(sld, layer_idx, layer_name)
    #print("-----")
    #print(str(m))
    #with open("sld_map.map", "w") as f:
    #    f.write(str(m))

    #with open("test_sld.png", "wb") as f:
    #    f.write(m.draw_buffer())

def test_convert_string():

    sld = """
        <?xml version="1.0" ?><StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">  
          <NamedLayer>    
            <Name>TestLayer</Name>    
            <UserStyle>      
              <FeatureTypeStyle>        
                <Rule>          
                  <PolygonSymbolizer>            
                    <Fill>              
                      <CssParameter name="fill">#0000ff</CssParameter>              
                    </Fill>            
                    <Stroke>              
                      <CssParameter name="stroke">#020202</CssParameter>              
                      <CssParameter name="stroke-width">1.00</CssParameter>              
                    </Stroke>            
                  </PolygonSymbolizer>          
                </Rule>        
              </FeatureTypeStyle>      
            </UserStyle>    
          </NamedLayer>  
        </StyledLayerDescriptor>
"""

    print(sld)

    l = ms.convert_sld(sld)
    print(l)
    return

    layer = ms.Layer()
    print(layer)

    s = """
    LAYER
        STATUS DEFAULT
        TYPE POLYGON
        NAME "pointer"
        PROJECTION
            "init=epsg:4326"
        END
        CLASS          
            STYLE
                MINSIZE 80
                MAXSIZE 120
                SYMBOL "pointer-sym"
                SIZE 400
            END
        END
    END
    """
    print(layer.numclasses)
    #layer.numclasses = 1
    print(layer.loads(s))
    print(layer)



def run_tests():  

    pytest.main(["tests/test_sld.py"])

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    #test_map_from_string()
    # test_convert_string()
    test_dumps()
    print("Done!")