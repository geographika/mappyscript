http://www.swig.org/Doc1.3/SWIG.html#SWIG_nn47

    /* File : header.h */

    #include <stdio.h>
    #include <math.h>

    extern int foo(double);
    extern double bar(int, int);
    extern void dump(FILE *f);


    /* File : interface.i */
    %module mymodule
    %{
    #include "header.h"
    %}
    extern int foo(double);
    extern double bar(int, int);
    extern void dump(FILE *f);

5.7.3 Why use separate interface files?

Although SWIG can parse many header files, it is more common to write a special .i file defining the interface to a package. 
There are several reasons why you might want to do this:

It is rarely necessary to access every single function in a large package. Many C functions might have little or no use in a scripted 
environment. Therefore, why wrap them?
Separate interface files provide an opportunity to provide more precise rules about how an interface is to be constructed.
Interface files can provide more structure and organization.
SWIG can't parse certain definitions that appear in header files. Having a separate file allows you to eliminate or work around these problems.
Interface files provide a more precise definition of what the interface is. Users wanting to extend the system can go to the 
interface file and immediately see what is available without having to dig it out of header files.


5.5.6 Adding member functions to C structures
http://www.swig.org/Doc1.3/SWIG.html

SWIG provides a special %extend directive that makes it possible to attach methods to C structures for purposes of building an 
object oriented interface. 
Suppose you have a C header file with the following declaration :



https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/python/wxs.py
OWSRequest is a SWIG extended version of cgiRequestObj 
See https://github.com/mapserver/mapserver/blob/branch-7-0/mapscript/swiginc/owsrequest.i

See https://github.com/mapserver/mapserver/blob/branch-7-0/cgiutil.c#L434

https://github.com/mapserver/mapserver/blob/branch-7-0/mapows.h