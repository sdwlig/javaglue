SHELL := /bin/bash
SYS:=`uname -s|sed -e 's/.*CYGWIN.*/win32/`

jghome=$(CURDIR)
jg=$(CURDIR)/scripts

# javaglue applibname libname  outputDirectory pathToIgnoreList inputDirectories...
# cd /tmp just to verify that no relative files are written.
ex:
	-mkdir $(jghome)/build
	$(jg)/javaglue app jg $(jghome)/build $(jghome)/ignore_list.xml $(jghome)/examples/example/*
	$(jg)/javaglue.compile app $(jghome)/build
	$(MAKE) extest

exapp:
	cp -r $(jghome)/examples/Ex $(jghome)/build/
	cp $(jghome)/build/*.jar  $(jghome)/build/Ex/libs/
	-mkdir $(jghome)/build/Ex/jni
	cp -r $(jghome)/build/cpp/*  $(jghome)/build/Ex/jni/
	cp $(jghome)/src/ndk/Android.mk $(jghome)/build/Ex/jni/Android.mk.orig
	cd $(jghome)/build/Ex/jni && $(jghome)/scripts/ndkprep
	cd $(jghome)/build/Ex/ && android update project -t 2 -p ./
	cd $(jghome)/build/Ex && ndk-build
	cd $(jghome)/build/Ex && $(jghome)/extern/ant/bin/ant release

extest:
	-mkdir $(jghome)/build
	$(jg)/jgjs $(jghome)/build -e 't = new org.javaglue.Test(); print(t); t.setString("Hi"); p = t.getCString(); s = t.toString(p); print(s);'
	$(jg)/jgjs $(jghome)/build examples/example/test.js
	$(MAKE) exgt
	echo To build docs: make exdoxy

exgt:
	$(jg)/jggroovy $(jghome)/build  -e 'import org.javaglue.*; t = new org.javaglue.Test();'
	$(jg)/jggroovy $(jghome)/build -e 't = new org.javaglue.Test(); print(t); t.setString("Hi"); p = t.getCString(); s = t.toString(p); print(s);'
#; print(t); t.setString("Hi"); p = t.getCString(); s = t.toString(p); print(s);'

exdoxy:
	-rm -rf $(jghome)/build/html
	$(jg)/javaglue.doxygen app App $(jghome)/build $(jghome)/build/java $(jghome)/build/inputfiles

exmin:
	cd /tmp && $(jg)/javaglue app jg $(jghome)/build $(jghome)/ignore_list.xml $(jghome)/examples/examplemin/*
	$(MAKE) exminc

exminc:
	$(jg)/javaglue.compile app $(jghome)/build
	$(jghome)/test $(jg)

clean:
	rm -rf $(jghome)/build/*
	rm -rf $(jghome)/src/java/build/java/class/*

