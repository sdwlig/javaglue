
if(DEBUGCMAKE)
  MESSAGE("DEBUG: TOP begin : $ENV{PWD}, ANDROIDVER: ${ANDROIDVER}, CMAKE_SYSTEM_NAME is ${CMAKE_SYSTEM_NAME}" )
  MESSAGE("DEBUG: TOP begin : ThirdpartyLibs are ${ThirdpartyLibs}")
endif(DEBUGCMAKE)

# set(AllLibs )

####################################################
# Set Variables
if ("${XbigOut}" STREQUAL "")
   set (XbigOut "${CMAKE_CURRENT_BINARY_DIR}")
endif ()
if ("${XbigLibName}" STREQUAL "")
   set (XbigLibName "javaglue")
endif ()
if ("${XbigAppLibName}" STREQUAL "")
   set (XbigAppLibName "jgapp")
endif ()
if ("${JdocOut}" STREQUAL "")
   set (JdocOut "${CMAKE_CURRENT_BINARY_DIR}")
endif ()

if ("${ARCH}" STREQUAL "osx_x86" )
	set(SysLibsDashL -L/opt/local/lib)
	set(JAVAARCH -d32)
endif ()

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
   set(DebugArg -g)
endif ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")

set(SharedFlag -shared)
if ("${ARCH}" STREQUAL "android_arm" )
	# file(GLOB_RECURSE SslLib   ${ThirdpartyTop}/lib/${ARCH}/openssl/${CMAKE_BUILD_TYPE}/*${CMAKE_SHARED_LIBRARY_SUFFIX} )
	set(ARCHFLAGS -Wl,-shared,-Bsymbolic -lstdc++)
#	set(NdkLibs ${SslLib} -L${SYSROOT}/usr/lib/ -L${ThirdpartyLibs}/libcurl/${CMAKE_BUILD_TYPE}  -lcurl -lz -llog ${JNIGRAPHICSLIB} -lstdc++ -lgcc -lm -ldl -lc)
	set(NdkLibs -L${ANDROID_LIBS_DIR} -L${SYSROOT}/usr/lib -L${ThirdpartyLibs}/libcurl/${CMAKE_BUILD_TYPE} -l${ZLIB} -llog ${JNIGRAPHICSLIB} -lstdc++ -lgcc -lm -ldl -lc)
	# set(XbigSysLibs -L${ThirdpartyLibs}/stlport/${CMAKE_BUILD_TYPE} ${NdkLibs} ${AndroidSysLibs} )
	set(XbigSysLibs ${AndroidSysLibs} ${NdkLibs})
	set(NoStdLib -nostdlib )
	set(NoUndefined -Wl,--no-undefined )
	set(LinkLibs ${AllLibs} ${ThirdLibs} )
	set(WholeArchive -Wl,--whole-archive --gc-sections)
	set(NoWholeArchive -Wl,--no-whole-archive)
	set(SONAMEXbig -Wl,--soname,lib${XbigLibName}.so ) 
	set(SONAMEXbigApp -Wl,--soname,lib${XbigAppLibName}.so ) 
	set (RANLIB ${ANDROID_TOOLCHAIN}/arm-eabi-ranlib)  
	# set(RunBasicTest echo Cannot run this test on a non-Android host.)

else ("${ARCH}" STREQUAL "android_arm" ) # This is the default for Unix, i.e. Linux, and perhaps Windows+Cygwin
     	# This is cool, but not that great during a build...  Use jdb/gdb debugging instead.
	# set(RunBasicTest env LD_LIBRARY_PATH=${XbigOut}/${ARCH} ${JAVA_RUNTIME} '-XX:OnError=gdb - %p' ${JAVAARCH} -Djava.library.path=${XbigOut}/${ARCH} -cp ${XbigOut}/xbig.jar test.BasicTests) 

	# set(BTClassPath "${XbigOut}/xbig.jar:${ThirdpartyTop}/java/apache-mime4j-0.6.jar:${ThirdpartyTop}/java/commons-codec-1.3.jar:${ThirdpartyTop}/java/commons-logging-1.1.1.jar:${ThirdpartyTop}/java/httpclient-4.0.1.jar:${ThirdpartyTop}/java/httpcore-4.0.1.jar:${ThirdpartyTop}/java/httpmime-4.0.1.jar:${ThirdpartyTop}/java/junit-4.8.2.jar")
	#set(JavaDebug -Xdebug -Xrunjdwp:transport=dt_socket,address=9000,server=y,suspend=y)
	#set(RunBasicTest env LD_LIBRARY_PATH=${XbigOut}/${ARCH} ${JAVA_RUNTIME} ${JAVAARCH} -Djava.library.path=${XbigOut}/${ARCH} -cp ${BTClassPath} ${JavaDebug} org.junit.runner.JUnitCore test.BasicTests) 

	set(WholeArchive -Wl,--whole-archive --gc-sections)
	set(NoWholeArchive -Wl,--no-whole-archive)
	set(XbigSysLibs ${SysLibsDashL} ${Syslibs})
	set(LinkLibs ${AllLibs} ${ThirdLibs} )
	set (RANLIB ranlib)  

endif ("${ARCH}" STREQUAL "android_arm" )

set(JNILIBSUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")

# Now override what deviates from Unix/Linux:
if ("${ARCH}" STREQUAL "osx_x86" )
	set( PLATFORM_LINK_FLAGS "${PLATFORM_LINK_FLAGS} -framework Foundation -framework ApplicationServices -framework IOKit -framework Security" )
	set (CMAKE_EXE_LINKER_FLAGS ${PLATFORM_LINK_FLAGS})
	find_library(Foun Foundation)
	find_library(Appl ApplicationServices)
	find_library(IOK IOKit)
	find_library(Sec Security)
	# target_link_libraries( xbig ${Foun} ${Appl} ${IOK} ${Sec}  )

	# This will likely break if  you have more than one architecture selected...	# Not to mention the link will be wrong.
	set(ARCHFLAGS -arch ${CMAKE_OSX_ARCHITECTURES})
	set(NoStdLib "")
	# set(NoStdLib "-Z") # If we actually needed it...
	set(WholeArchive "-force_load")
	set(NoWholeArchive "")
	set(SysFrameworks -framework CoreFoundation -framework ApplicationServices -framework Security -framework IOKit -framework Foundation -lobjc)
	# http://developer.apple.com/java/faq/development.html#anchor5
	set(JNILIBSUFFIX ".jnilib")
 
	set(LinkLibs ${AllLibs} ${ThirdLibs})  
	set (RANLIB echo)
	set(SharedFlag -dynamiclib)
endif ("${ARCH}" STREQUAL "osx_x86" )

link_directories( ${PLATFORM_LIBS} )
set(LibJar ${XbigOut}/lib.jar)

########################################
# Libraries: Xbig generated, xbig provided, and application glue / binding utility code.

file(GLOB_RECURSE BuiltSrcs ${CMAKE_CURRENT_BINARY_DIR}/build/cpp/src/lib/*.cpp)
file(GLOB_RECURSE XbigSrcs ${XBIG}/src/c/src/lib/*.cpp)
file(GLOB_RECURSE BindingSrcs ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp/*.cpp)

# Add sources here and directory for JavaSrcC below:
file(GLOB_RECURSE XbigJavaSrcs ${XBIG}/src/java/*.java ${CMAKE_CURRENT_BINARY_DIR}/build/javagen/*.java)
file(GLOB_RECURSE XbigJava2Srcs ${XBIG}/src/java2/*.java )
file(GLOB_RECURSE BuiltJavaSrcs ${CMAKE_CURRENT_BINARY_DIR}/build/java/*.java)
file(GLOB_RECURSE BindingJavaSrcs ${CMAKE_CURRENT_SOURCE_DIR}/src/java/*.java)
file(GLOB_RECURSE SsxSrcs ${ThirdpartyTop}/src/ssx/src/*.java)
# message("JavaGlueSrcs for Xbig in ThirdpartyTop: ${ThirdpartyTop}: ${JavaGlueSrcs}")
# message("BindingJavaSrcs for Xbig: ${BindingJavaSrcs}")

# App provided
# file(GLOB_RECURSE XbigInputs ${XBIGINPUT}/*.h)
# message("XbigInputs: ${XbigInputs}")
set (XbigInputsAll ${XbigInputs} ${XBIG}/src/c/include/basedelete.h)

set(JavaGlueJavaSrc ${XbigJavaSrcs} ${BuiltJavaSrcs} ${SsxSrcs})
set(AppJavaSrc ${XbigJava2Srcs} ${BindingJavaSrcs} ${XbigExtraJavaSrcs} )
set(JavaSrcC ${XBIG}/src/java ${CMAKE_CURRENT_BINARY_DIR}/build/java ${CMAKE_CURRENT_SOURCE_DIR}/src/java ${ThirdpartyTop}/src/Ssx/src )
# message("JavaSrc for Xbig: ${JavaSrc}")

# App provided
# include_directories ( ${XBIGCIncludes} "${XBIG}/src/c/include" "${CMAKE_CURRENT_BINARY_DIR}/build/cpp/include")
# System provided:
include_directories ( ${PLATFORM_INCLUDES} ${JAVA_INCLUDE_PATH} ${JAVA_INCLUDE_PATH2} ${JNI_INCLUDE_DIRS} )
# link_directories( ${FreetypeLib}/${CMAKE_BUILD_TYPE} )
#MESSAGE("PLATFORM_INCLUDES: ${PLATFORM_INCLUDES} ${JAVA_INCLUDE_PATH} ${JNI_INCLUDE_DIRS}")

add_definitions(${PLATFORM_C_FLAGS})

set (XBIGOUTFILE ${CMAKE_CURRENT_BINARY_DIR}/xbigdone.c)  
set_source_files_properties(${XBIGOUTFILE} PROPERTIES GENERATED true )
add_library(${XbigAppLibName} STATIC ${BuiltSrcs} ${BindingSrcs} ${XBIGOUTFILE} )
add_library(${XbigLibName} STATIC ${XbigSrcs} ${XBIGOUTFILE} )

########################################
# Xbig generate

set (XSLTEXTCLASS "${XBIG}/src/java/build/java/class/org/xbig/xsltext/XsltExt.class")
# Because we can't tell if a previous run created a version with the wrong compiler,
# use this to always compile a new class file.  Not currently used.
set (XSLTEXTALWAYS "${XBIG}/src/java/build/java/class/org/xbig/xsltext/XsltExt.always")
add_custom_command(
  OUTPUT ${XSLTEXTCLASS} ${XSLTEXTALWAYS}
  DEPENDS ${XBIG}/src/java/org/xbig/xsltext/XsltExt.java ${XbigInputsAll}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${XBIG}/src/java/build/java/class
  COMMAND ${JAVA_COMPILE} ${DebugArg} ${XBIG}/src/java/org/xbig/xsltext/XsltExt.java -d ${XBIG}/src/java/build/java/class
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# Create the statics to load the shared libraries at runtime.
# Note that while this is generated code, it is directly dependend upon by the base JavaGlue code, so it should be compiled into that jar.
message("Create LoadLibraries")
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/build/javagen/gen/javaglue/LoadLibraries.java
  "package gen.javaglue; public class LoadLibraries { public boolean loaded = false; static { System.loadLibrary(\"${XbigLibName}\"); System.loadLibrary(\"${XbigAppLibName}\"); } }")
# Could use System.loadLibrary("stlport_shared");, but should be worse not better...
# ndk5/docs/CPLUSPLUS-SUPPORT.html

add_custom_command(
  OUTPUT ${XBIGOUTFILE}
  DEPENDS ${XbigInputsAll} # ${XSLTEXTCLASS}
  COMMAND ${CMAKE_COMMAND} -E copy ${XBIG}/build.xml ${CMAKE_CURRENT_BINARY_DIR}
  COMMAND ${CMAKE_COMMAND} -E copy ${XBIG}/src/c/include/basedelete.h ${XBIGINPUT}
  # Force the next 2 commands in case the JDK was changed.
  COMMAND ${CMAKE_COMMAND} -E make_directory ${XBIG}/src/java/build/java/class
  COMMAND ${JAVA_COMPILE} ${DebugArg} ${XBIG}/src/java/org/xbig/xsltext/XsltExt.java -d ${XBIG}/src/java/build/java/class
  # Now generate C++ and Java code from C/C++ headers:
  COMMAND ant -Dxbig.home=${XBIG} -Dxbig.input=${XBIGINPUT} -Dxbig.libname=${XbigLibName} -Dxbig.applibname=${XbigAppLibName} -Dxbig.ignorelist=${XBIGIGNORELIST} -f build.xml
  COMMAND ${CMAKE_COMMAND} -E make_directory org/gen/javaglue
 # This should force a re-cmake on the next make to pick up the created files.
  COMMAND ${CMAKE_COMMAND} -E remove ${NOREMAKE}
  COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_SOURCE_DIR}/CMakeLists.txt
  COMMAND ${CMAKE_COMMAND} -E touch ${XBIGOUTFILE}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# xbig
 set (XbigShared ${XbigOut}/${ARCH}/lib${XbigLibName}${JNILIBSUFFIX})
 set (XbigAppShared ${XbigOut}/${ARCH}/lib${XbigAppLibName}${JNILIBSUFFIX})
 add_custom_command(
  OUTPUT  ${XbigShared} ${XbigAppShared}
  DEPENDS ${XbigSrcs} ${TestSrcs} ${XBIGOUTFILE} ${AllLibs} ${XbigLibName} ${XbigAppLibName} ${NOREMAKE}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${XbigOut}/${ARCH}
  COMMAND ${CMAKE_CXX_COMPILER} ${DebugArg} ${SharedFlag} ${ARCHFLAGS} -o ${XbigShared} -gfull ${SONAMEXbig} ${WholeArchive} ${LIBRARY_OUTPUT_PATH}/lib${XbigLibName}${CMAKE_STATIC_LIBRARY_SUFFIX} ${NoWholeArchive} ${NoStdLib} ${SysFrameworks} ${XbigSysLibs} ${NoUndefined}
  COMMAND ${CMAKE_CXX_COMPILER} ${DebugArg} ${SharedFlag} ${ARCHFLAGS} -o ${XbigAppShared} -gfull ${SONAMEXbigApp} ${WholeArchive} ${LIBRARY_OUTPUT_PATH}/lib${XbigAppLibName}${CMAKE_STATIC_LIBRARY_SUFFIX} ${NoWholeArchive} ${ProjectLibs} ${XbigShared} ${NoStdLib} ${LinkLibs} ${SysFrameworks} ${XbigSysLibs} ${NoUndefined}
  WORKING_DIRECTORY ${XbigOut}
)

# xbigsrc.jar
# set(JavaSrcC ${XBIG}/src/java ${CMAKE_CURRENT_BINARY_DIR}/build/java ${CMAKE_CURRENT_SOURCE_DIR}/src/java ${ThirdpartyTop}/src/ssx/src )
set(TMPJSRC ${CMAKE_CURRENT_BINARY_DIR}/tmpjsrc)
set(jdocout ${TMPJSRC}/out/javadoc)
message("jdocout: ${jdocout}")

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/javaglueclasses ${CMAKE_CURRENT_BINARY_DIR}/appclasses
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/javaglueclasses
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/appclasses
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

#message("====================================================================")
#message("JavaGlue Sources: ${JavaGlueJavaSrc}")
#message("App Sources: ${AppJavaSrc}")

# javaglue.jar
add_custom_command(
  OUTPUT ${XbigOut}/${XbigLibName}.jar
  DEPENDS ${JavaGlueJavaSrc} ${NOREMAKE} ${CMAKE_CURRENT_BINARY_DIR}/javaglueclasses
  COMMAND ${CMAKE_COMMAND} -E make_directory ${XbigOut}/${ARCH}
  COMMAND ${JAVA_COMPILE} ${DebugArg} -classpath ${XbigExtraJavaLibs} ${JavaGlueJavaSrc} -d ${CMAKE_CURRENT_BINARY_DIR}/javaglueclasses
  COMMAND ${JAVA_ARCHIVE} cf ${XbigOut}/${XbigLibName}.jar org gen
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/javaglueclasses
)
# app.jar
add_custom_command(
  OUTPUT ${XbigOut}/${XbigAppLibName}.jar
  DEPENDS ${JavaSrc} ${NOREMAKE} ${CMAKE_CURRENT_BINARY_DIR}/appclasses
  COMMAND ${CMAKE_COMMAND} -E make_directory ${XbigOut}/${ARCH}
  COMMAND ${JAVA_COMPILE} ${DebugArg} -classpath ${XbigOut}/${XbigLibName}.jar:${XbigExtraJavaLibs} ${AppJavaSrc} -d ${CMAKE_CURRENT_BINARY_DIR}/appclasses
  COMMAND ${JAVA_ARCHIVE} cf ${XbigOut}/${XbigAppLibName}.jar org ${JavaGlueTopLevelJava}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/appclasses
)

add_custom_command(
  OUTPUT ${TMPJSRC}/out/org
  DEPENDS ${JavaSrc} ${NOREMAKE}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${TMPJSRC}
  COMMAND svn export --force ${XBIG}/src/java ${TMPJSRC}/1
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/build/java ${TMPJSRC}/out
  COMMAND svn export --force ${CMAKE_CURRENT_SOURCE_DIR}/src/java ${TMPJSRC}/3
  COMMAND svn export --force ${ThirdpartyTop}/src/ssx/src ${TMPJSRC}/4
  COMMAND ${CMAKE_COMMAND} -E make_directory ${TMPJSRC}/out
  COMMAND ${CMAKE_COMMAND} -E make_directory ${TMPJSRC}/out/javadoc
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${TMPJSRC}/1 ${TMPJSRC}/out
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${TMPJSRC}/3 ${TMPJSRC}/out
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${TMPJSRC}/4 ${TMPJSRC}/out
  # COMMAND ${JAVA_ARCHIVE} cf ${XbigOut}/xbigsrc.jar -C ${TMPJSRC}/out .
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# Javadoc
add_custom_command(
  OUTPUT ${jdocout}/index.html
  DEPENDS ${JavaSrc} ${TMPJSRC}/out/org ${NOREMAKE}
  # COMMAND ${CMAKE_COMMAND} -E remove_directory ${jdocout}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${jdocout}
  # COMMAND javadoc -sourcepath ${TMPJSRC}/out -classpath ${XBIG}/src/java:src:${CMAKE_CURRENT_BINARY_DIR}/build/java${XbigExtraJavaLibs} -subpackages core:org:test -use -d ${jdocout}
  COMMAND javadoc -sourcepath ${TMPJSRC}/out -classpath ${XBIG}/src/java:src:${CMAKE_CURRENT_BINARY_DIR}/build/java${XbigExtraJavaLibs} -linksource -subpackages core:org:test -use -d ${jdocout}
  WORKING_DIRECTORY ${TMPJSRC}/out
)

add_custom_command(
  OUTPUT ${XbigOut}/xbigsrc.jar
  DEPENDS ${JavaSrc} ${TMPJSRC}/out/org ${jdocout}/index.html ${NOREMAKE}
  COMMAND ${JAVA_ARCHIVE} cf ${XbigOut}/xbigsrc.jar -C ${TMPJSRC}/out .
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# javadoc example
add_custom_command(
  OUTPUT ${JdocOut}/index.html
  DEPENDS ${JavaSrc} ${NOREMAKE}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${JdocOut}
  COMMAND ${JAVA_DOC} ${JavaSrc} -d ${JdocOut}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

set(TestsDone "${CMAKE_CURRENT_BINARY_DIR}/TestsDone.txt")
add_custom_command(
    OUTPUT ${TestsDone}
    DEPENDS  ${XbigOut}/${XbigLibName}.jar ${XbigOut}/${XbigAppLibName}.jar ${XbigShared} ${XBIGOUTFILE} ${NOREMAKE}
    COMMAND ${RunBasicTest}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)


add_custom_target( xbigall DEPENDS ${jdocout}/index.html ${TestsDone} ${XbigOut}/xbigsrc.jar)
add_custom_target( xbignodoc ALL DEPENDS ${TestsDone} )
