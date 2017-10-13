SLD for layers. Parse map, and simply set a single layer's STATUS to ON. 

Same for legends. 


Querying

http://mapserver.org/mapscript/querying.html#querying-overview

https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/python/tests/cases/layertest.py
https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/layer.i

self.layer = self.map.getLayerByName('POINT')
self.layer.template = 'foo'
self.layer.queryByAttributes(self.map, "FNAME", '"A Point"', mapscript.MS_MULTIPLE)
assert self.layer.getNumResults() == 1

    int queryByAttributes(mapObj *map, char *qitem, char *qstring, int mode) 
    {
        int status;
        int retval;

        msInitQuery(&(map->query));
        
        map->query.type = MS_QUERY_BY_FILTER;
        map->query.mode = mode;

        if(qitem) map->query.filteritem = msStrdup(qitem);
        if(qstring) {
          msInitExpression(&map->query.filter);
          msLoadExpressionString(&map->query.filter, qstring);
        }

        map->query.layer = self->index;
        map->query.rect = map->extent;

        status = self->status;
        self->status = MS_ON;
        retval = msQueryByFilter(map);
        self->status = status;

        return retval;
    }

msGetLayerIndex(map, name);

https://github.com/mapserver/mapserver/blob/branch-7-0/mapquery.c

Layers need a template to query


    resultCacheObj *getResults(void)
    {
        return layer->resultcache;
    }


Don't implement. Use WFS instead.


processTemplate( int generateimages, string names[], string values[], int numitems )

    %newobject processTemplate;
    char *processTemplate(int bGenerateImages, char **names, char **values,
                          int numentries)
    {
        return msProcessTemplate(self, bGenerateImages, names, values,
                                 numentries);
    }

https://github.com/mapserver/mapserver/blob/66309eebb7ba0dc70469efeb40f865a8e88fafbd/mapscript/swiginc/map.i
https://github.com/mapserver/mapserver/blob/66309eebb7ba0dc70469efeb40f865a8e88fafbd/maptemplate.c#L4701