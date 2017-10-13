Cython Notes
============

Structs
-------

http://docs.cython.org/en/latest/src/userguide/external_C_code.html#styles-of-struct-union-and-enum-declaration
For archaic reasons C uses the keyword void to declare a function taking no parameters. In Cython as in Python, simply declare such functions as foo().

.. code-block:: bat

    /* mapObj msLoadMapFromString(char* buffer, char* new_mappath) */  

Implementation files carry a .pyx suffix
Definition files carry a .pxd suffix

Build Errors
------------

* ``Warning: Extension name 'mappyscript' does not match fully qualified name 'mappyscript.mappyscript' of 'mappyscript/mappyscript.pyx'``
* ``mappyscript.obj : warning LNK4197: export 'initmappyscript' specified multiple times; using first specification`` - can be safely ignored? 
  https://stackoverflow.com/questions/37596516/warning-lnk4197-export-pyinit-python-module-name-specified-multiple-times-us

* ``mappyscript.obj : error LNK2019: unresolved external symbol msGetVersion referenced in function __pyx_pf_11mappyscript_11mappyscript_get_version``
* ``build\lib.win-amd64-2.7\mappyscript.pyd : fatal error LNK1120: 1 unresolved externals``

Check paths for build

TypeError: expected bytes, str found


--

cython unresolved external symbol
__declspec()

#if defined(_WIN32) && !defined(__CYGWIN__)
#  define MS_DLL_EXPORT     __declspec(dllexport)

Must have MS_DLL_EXPORT (used to point to __declspec())
Error only occurs when using in .pyx, not when declared in .pxd e.g. msSLDParseRule in mapogcsld.h
http://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html

    _mappyscript.obj : error LNK2019: unresolved external symbol msSLDParseRule referenced in function __pyx_pf_11mappyscript_12_mappyscript_14convert_sld
    build\lib.win-amd64-2.7\mappyscript\_mappyscript.pyd : fatal error LNK1120: 1 unresolved externals

See also https://github.com/mapserver/mapserver/issues/851 - MS_DLL_EXPORT was missing on some functions. 

You could provide your own my_lapack.h header and do 'cdef extern from "my_lapack.h": ...'.  This would allow you complete control over the function prototype. ?

Pointers
--------

https://stackoverflow.com/questions/2660633/declaring-pointers-asterisk-on-the-left-or-right-of-the-space-between-the-type

It's a matter of preference, and somewhat of a holy war, just like brace style.

The style

someType* somePtr;
is emphasizing the type of the pointer variable. It is saying, essentially, "the type of somePtr is pointer-to-someType".

The style

someType *somePtr
is emphasizing the type of the pointed-to data. It is saying, essentially, "the type of data pointed to by somePtr is someType".

Also in examples:

http://docs.cython.org/en/latest/src/tutorial/clibraries.html

Queue *queue_new(void);

Queue* queue_new()


_cmap[0] = tmp # create a pointer to the reference
#cmap = tmp[0] # dereference the pointer

    cdef public ms.mapObj* _get_mapObj(self):
        cdef ms.mapObj* cmap
        tmp = self._cmap
        cmap = tmp # set this or errors about "Storing unsafe C derivative of temporary Python reference""