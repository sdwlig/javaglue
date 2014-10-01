

# Set by app, usually in bindings/java/CMakeLists.txt:
# Name for libraries containing JavaGlue LGPL code
#set (XbigLibName "javaglue")
# Name for libraries with appication and generated code
#set (XbigAppLibName "jgapp")
#set(XBIG ${CMAKE_SOURCE_DIR}/tools/javaglue)
#set(XBIGINPUT ${CMAKE_SOURCE_DIR}/include) 
#set(XBIGCIncludes ${CMAKE_SOURCE_DIR}/include ${CMAKE_SOURCE_DIR}/include/projectname)
#set (XbigOut "${CMAKE_CURRENT_BINARY_DIR}")
# Libraries to link against, usually like this, one per line
#set(AllLibs
#    ${BinaryTop}/libname1/src/libname1${CMAKE_STATIC_LIBRARY_SUFFIX}
#)

# Optionally set by app:
# If XbigInputs and include_directories are built by app
#set (JavaGlueCustomInputs "true")
# For when Java packages start with anything other than org and test:
# set(XbigTopLevelJava core)
#set(XBIGIGNORELIST "${XBIG}/ignore_list.xml") # This could be a project-specific, modified copy
# Jars to link Java test with:
#set(XbigExtaJavaLibs :...:...)
# Libraries to link C/C++ code with:
#set(AndroidSysLibs -lcurl -L... -l...)
#set(Syslibs -l...)
#file(GLOB_RECURSE ThirdLibs ${ThirdpartyLibs/*/${CMAKE_BUILD_TYPE}/*${CMAKE_STATIC_LIBRARY_SUFFICE})
# The command line to run for a basic regression test:
# set(RunBasicTest env .....)

# End example configuration parameters

if ("${XBIGIGNORELIST}" STREQUAL "")
  # This could be a project-specific, modified copy
  set(XBIGIGNORELIST "${XBIG}/ignore_list.xml")
endif ("${XBIGIGNORELIST}" STREQUAL "")

# CMAKE_OSX_ARCHITECTURES
# link_directories( ${PLATFORM_LIBS} )
# set(LibJar ${XbigOut}/lib.jar)

# These are the default paths for C++/Java app binding code:
#file(GLOB_RECURSE BindingSrcs ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp/*.cpp)
#file(GLOB_RECURSE BindingJavaSrcs ${CMAKE_CURRENT_SOURCE_DIR}/src/java/*.java)
# This is the App C++ inputs for generation:
# These should be conditionalized for overriding from app:
if ("${JavaGlueCustomInputs}" STREQUAL "")
file(GLOB_RECURSE XbigInputs ${XBIGINPUT}/*.h)
include_directories ( ${ALLINCLUDES} ${XBIGCIncludes} "${XBIG}/src/c/include" "${XBIG}/src/c/include/base" "${CMAKE_CURRENT_BINARY_DIR}/build/cpp/include")
endif ("${JavaGlueCustomInputs}" STREQUAL "")

add_custom_command(
  OUTPUT ${Out}/javatest.jar
  DEPENDS ${JavaSrc} ${NOREMAKE}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${XbigOut}/${ARCH}
  COMMAND ${JAVA_COMPILE} ${DebugArg} -classpath ${XBIG}/src/java:src:${CMAKE_CURRENT_BINARY_DIR}/build/java${XbigExtraJavaLibs} ${JavaSrc} -d ${CMAKE_CURRENT_BINARY_DIR}
 COMMAND ${JAVA_ARCHIVE} cf ${XbigOut}/xbig.jar org ${JavaGlueTopLevelJava}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/src/java
)

# SslLib NdkLibs SysLibs LinkLibs
# Runs compile time regression test:
if ("${RunBasicTest}" STREQUAL "")
if ("${ARCH}" STREQUAL "android_arm" )
	set(RunBasicTest echo Cannot run this test on a non-Android host.)
else ( ) # This is the default for Unix, i.e. Linux, and perhaps Windows+Cygwin
     set (CMAKE_OSX_ARCHITECTURES "i386")
     set(JAVAARCH -d32)
     # set(RunBasicTest env LD_LIBRARY_PATH=${XbigOut}/${ARCH} ${JAVA_RUNTIME} "-XX:OnError='gdb - %p'" ${JAVAARCH} -Djava.library.path=${XbigOut}/${ARCH} -cp ${XbigOut}/javaglue.jar test.BasicTests) 
#     set(RunBasicTest env LD_LIBRARY_PATH=${XbigOut}/${ARCH} ${JAVA_RUNTIME}   ${JAVAARCH} -Djava.library.path=${Out}/${ARCH} -cp ${Out}/javaglue.jar test.BasicTests)  
     set(RunBasicTest env LD_LIBRARY_PATH=${XbigOut}/${ARCH} ${JAVA_RUNTIME}   ${JAVAARCH} -Djava.library.path=${XbigOut}/${ARCH} -cp ${XbigOut}/javaglue.jar:${XbigOut}/app.jar test.BasicTests)  
endif ( )
endif ("${RunBasicTest}" STREQUAL "")

include(${XBIG}/javaglue.cmake)
