# API reference

The public C++ API is declared below the `embedded_linux_template` namespace. Doxygen reads the
headers and implementation sources, emits XML, and Breathe converts that XML into Sphinx nodes.

```{doxygennamespace} embedded_linux_template
:project: C++ Embedded Linux Repository Template
:members:
```

If this page is empty during a manual Sphinx invocation, generate Doxygen XML first or set
`DOXYGEN_XML_DIR` to the XML directory. The default location is
`../build/docs/doxygen/xml`, resolved relative to this `docs` directory.
