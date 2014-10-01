# Include in project that uses JavaGlue
# JAVAGLUE_DIR
# BUILD_DIR
file(GLOB_RECURSE JAVAGLUE_INCLUDES "${JAVAGLUE_DIR}/src/c/include/*.h")
file(GLOB_RECURSE JAVAGLUE_CPP "${JAVAGLUE_DIR}/src/c/src/lib/*.cpp")

src/java

