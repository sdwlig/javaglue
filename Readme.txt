JavaGlue
See http://javaglue.com for basic background.

The example Makefile illustrates the main steps:
# JavaGlue input is a set of C++ .h files.
# Output: Copies of JavaGlue C++ .h/.cpp files.
#         Generated C++ .h/.cpp files.
#         JavaGlue library and generated Java files compiled into one or two jar files.

Usage: javaglue appLibName libName buildDir ignoreList.xml inputDir

The generated binaries:
  jar files are in buildDir/*.jar.
  shared libraries files are in buildDir/*.{so,dylib,dll}

Source files (for debugging) are in:
  buildDir/java
  buildDir/cpp/{include,src}
