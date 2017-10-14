mappyfile
=========

| |Appveyor| |Build Status| 

A minimalist Python library for MapServer built using Cython. 

Quick Start
-----------

.. code-block:: console

    pip install mappyscript

.. code-block:: python

    import os
    DLL_LOCATION = r"C:\MapServer\bin"
    os.environ['PATH'] = DLL_LOCATION + ';' + os.environ['PATH']
    import mappyscript as ms


.. |Appveyor| image:: https://ci.appveyor.com/api/projects/status/cbwq9epx3yor7fp9?svg=true
   :target: https://ci.appveyor.com/project/SethG/mappyscript

.. |Build Status| image:: https://travis-ci.org/geographika/mappyscript.svg?branch=master
   :target: https://travis-ci.org/geographika/mappyscript
