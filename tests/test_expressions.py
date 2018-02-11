import os

try:
    import mappyscript as ms
except ImportError as ex:
    #DLL_LOCATION = r"C:\MapServer\bin" # works
    #DLL_LOCATION = r"D:\MapServer\release-1500-x64-gdal-mapserver\bin" # fails
    DLL_LOCATION = r"D:\MapServer\release-1800-x64-dev\release-1800-x64\bin" # works
    os.environ['PATH'] = DLL_LOCATION + ';' + os.environ['PATH']
    import mappyscript as ms

def test_map_from_string():

    s = """
MAP
    NAME "Test"
    EXTENT -10 -10 10 10
    SIZE 400 400

    LAYER
        NAME "TestLayer"
        STATUS ON
        TYPE POINT
        PROCESSING "ITEMS=field1,field2"
        FEATURE
            POINTS 0 0 END
            ITEMS "2;3"            
        END
        FEATURE
            POINTS 5 5 END
            ITEMS "5;6"            
        END
        CLASS
            #TEXT (([field1] ^ [field2] + 2) * 2)
            TEXT (-[field1])
            # following works with one feature shown
            #EXPRESSION (( [field1] eq 2 ) or ( [field1] eq 99 ))
            # with the following expression no features are shown
            # EXPRESSION ( [field1] eq 2 ) or ( [field1] eq 2 )
            LABEL
              COLOR  150 150 150
            END
        END
    END
END
    """

    m = ms.loads(s)
    ns = ms.dumps(m)
    print(ns)

    m.draw("D:/Temp/expression.png")

    #params = {
    #"SERVICE": "WFS",
    #"REQUEST": "GetFeature",
    #"VERSION": "1.1.0",
    #"TYPENAME": "TestLayer",
    #"MAXFEATURES": "1",
    #"OUTPUTFORMAT": "geojson",
    #}

    #result = ms.create_request(s, params)
    #ct = result["content_type"]
    #data = result["data"].decode('utf-8')
    
    #print(data)

test_map_from_string()
print("Done!")
