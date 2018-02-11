mappyfile
=========

| |Appveyor| |Build Status| 

A minimalist Python library for MapServer built using Cython. 

Quick Start
-----------

.. code-block:: console

    pip install mappyscript

..
    As it is a wheel file need to update pip from 6.1.1 to 9.0.1

    Get the following if using x64 bit

    (mappyfile-editor) C:\VirtualEnvs\mappyfile-editor\Scripts>pip install mappyscript==0.0.3
    Collecting mappyscript==0.0.3
      Could not find a version that satisfies the requirement mappyscript==0.0.3 (from versions: )
    No matching distribution found for mappyscript==0.0.3

.. code-block:: python

    import os
    DLL_LOCATION = r"C:\MapServer\bin"
    os.environ['PATH'] = DLL_LOCATION + ';' + os.environ['PATH']
    import mappyscript as ms


.. |Appveyor| image:: https://ci.appveyor.com/api/projects/status/cbwq9epx3yor7fp9?svg=true
   :target: https://ci.appveyor.com/project/SethG/mappyscript

.. |Build Status| image:: https://travis-ci.org/geographika/mappyscript.svg?branch=master
   :target: https://travis-ci.org/geographika/mappyscript
