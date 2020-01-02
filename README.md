A generic build environment.

- File source tree is organized in a form of packages.
- Each package located in its own directory.
- Package dependecies graph is created automatically from C/C++ include directives. It is also possible to define a dependency explicitely if needed.
- It is enforced that package dependencies is an acyclic graph.
- Each package is built into a shared library and checked for beign fully resolved.
- It is always possible to create an executable or a fully resolved shared library from every package.
- Multiple build flows are supported: 
    Using a native compiler,
    Using a cross compiler (a cross compiler is requited),
    Build kernel objects (a cross compiler and a linux kernel tree is required).
    Each flavor will store its own package tree dependencies.
- Debug and Release build modes are supported.

To build everything, please cd to "src" directory and run "make".
