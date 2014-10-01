/* This source file is part of XBiG
 *     (XSLT Bindings Generator)
 * For the latest info, see http://sourceforge.net/projects/javaglue/
 *
 * Copyright (c) 2005 netAllied GmbH, Tettnang
 * Also see acknowledgements in Readme.html
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place - Suite 330, Boston, MA 02111-1307, USA, or go to
 * http://www.gnu.org/copyleft/lesser.txt.
 */
#include <jni_base.h>
#include <stdio.h>
#include <iostream>
#include <string.h>
#include "basedelete.h"

#ifdef WIN32
#include <windows.h>

namespace org { namespace javaglue { namespace jni {
    
    void windowsStringConverter(JNIEnv* env, jstring jString, std::string& outString, int codePage)
    {
	// note: jchar and wchar_t are both 2 bytes with msvc
	const wchar_t* c_str = (const wchar_t*)env->GetStringChars(jString, 0);
	
	int requiredSize = WideCharToMultiByte( codePage, 0, c_str, -1,
					       0, 0, NULL, NULL );
	
	char * dest = new char[ requiredSize ];
	WideCharToMultiByte( codePage, 0, c_str, -1,
			    dest, requiredSize, NULL, NULL );
	outString = dest;
	delete[] dest;
	env->ReleaseStringChars(jString, (const jchar*)c_str);
    }
    
}}}
#endif

void Delete::byteVector(base::ByteVector* bv) { delete bv; }
void Delete::stringVector(base::StringVector* sv) { delete sv; }
void Delete::vectorByteVector(base::VectorByteVector* vbv) { delete vbv; }
void Delete::mapStringByteVector(base::MapStringByteVector* msbv) { delete msbv; }
void Delete::mapLongByteVector(base::MapLongByteVector* mlbv) { delete mlbv; }
void Delete::mapStringString(base::MapStringString* mss) { delete mss; }

std::string& org::javaglue::jni::to_stdstring(JNIEnv* env, jstring jString, std::string& outString) {
#ifdef WIN32
    windowsStringConverter(env, jString, outString, CP_ACP);
    return outString;
#else
    const char* c_str = env->GetStringUTFChars(jString, 0);
    outString = (c_str);
    env->ReleaseStringUTFChars(jString, c_str);
    return outString;
#endif
}

std::string& org::javaglue::jni::to_stdstringUTF8(JNIEnv* env, jstring jString, std::string& outString) {
#ifdef WIN32
    windowsStringConverter(env, jString, outString, CP_UTF8);
    return outString;
#else
    return to_stdstring(env, jString, outString);
#endif
}

char* org::javaglue::jni::to_cstring(JNIEnv* env, jstring jString, char* outString) {
    // TODO platform specific conversion
    char* c_str = (char*)env->GetStringUTFChars(jString, 0);
    strcpy (outString, c_str);
    env->ReleaseStringUTFChars(jString, c_str);
    return outString;
}


jstring org::javaglue::jni::to_jstring(JNIEnv* env, const std::string& str) {
    // TODO platform specific conversion
    return env->NewStringUTF(str.c_str());
}


jstring org::javaglue::jni::to_jstring(JNIEnv* env, const char* str) {
    // TODO platform specific conversion
    return env->NewStringUTF(str);
}

jsize org::javaglue::jni::getStringLength(JNIEnv* env, const jstring& jString) {
    return env->GetStringUTFLength(jString);
}

#ifdef __cplusplus
extern "C" {
#endif
    
    static void message(std::string msg) {
	fprintf(stdout, "%s\n", msg.c_str()); fflush(stderr);
    }
    static void error(int err, std::string msg) {
	fprintf(stderr, "%d %s\n", err, msg.c_str()); fflush(stderr);
    }
    
  // ByteArray member methods
  // Pins bytes for given byte array and outputs copy flag.
  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_pin(JNIEnv* env, jobject obj, jbyteArray ba, jbooleanArray copied) {
    long cflen = 0;
    jboolean cf;
    jbyte* bytes = 0; // NULL
    bytes = env->GetByteArrayElements(ba, &cf);
    if (copied && (cflen = env->GetArrayLength(copied))) {
      env->SetBooleanArrayRegion(copied, (jsize)0, (jsize)1, &cf);
    }
    return (jlong)bytes;
  }
  // Could also use a JNI_COMMIT version in the case of a copying JVM, but hopefully won't run into that anyway.
  JNIEXPORT jboolean JNICALL Java_org_javaglue_base_ByteArray_unpin(JNIEnv* env, jobject obj, jbyteArray ba, jlong bp) {
    env->ReleaseByteArrayElements(ba, (jbyte*) bp, 0);
    return true; // Just indicate we got this far.
  }

  // ByteArray static utility methods

  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_memsetByteVectorNative(JNIEnv* env, jobject obj, jlong bv, jlong b, jlong len) {
      base::ByteVector* bvp = (base::ByteVector*)bv;
      int size = len < bvp->size() ? len : bvp->size();
      memset((unsigned char*)&((*bvp)[0]), (unsigned char)b, size);
      return size;
  }
      JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_memsetBytePointerNative(JNIEnv* env, jobject obj, jlong bp, jlong b, jlong len) {
	unsigned char* bpp = (unsigned char*)bp;
        //fprintf(stderr, "memsetByteArrayNative: bpp: %p size: %ld fill: %ld firstbyte: %x\n", bpp, (long)len, (long)b, *(unsigned char *)bpp);
        memset(bpp, (unsigned char)b, len);
        //fprintf(stderr, "memsetByteArrayNative: after: firstbyte: %x\n", *(unsigned char *)bpp);
        return len;
  }


    // Should throw appropriate Java exceptions on errors here, especially inability to allocate.
    /* Allocate a Java byte array, copy std::vector<unsigned char> data into it. */
    JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_byteArrayNative(JNIEnv* env, jobject obj, jlong bv, jboolean fullAllocation) {
	return Java_org_javaglue_base_ByteArray_byteArrayDirect(env, bv, fullAllocation);
    }
    JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_byteArrayDirect(JNIEnv* env, jlong bv, jboolean fullAllocation) {
	base::ByteVector* bvp = (base::ByteVector*)bv;
	int size = bvp->size();
	jbyteArray ba = env->NewByteArray(fullAllocation ? bvp->capacity() : size);
	if (bvp->empty()) return ba;
	env->SetByteArrayRegion(ba, 0, size, (const jbyte*)&((*bvp)[0]));
	return ba;
    }
    
    JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_byteVectorNativeReserve(JNIEnv* env, jobject obj, jlong reserve) {
	base::ByteVector* bvp = new base::ByteVector(reserve);
	return (jlong)bvp;
    }
    
    JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_byteVectorNative(JNIEnv* env, jobject obj, jbyteArray ba, jlong reserve) {
	int size = env->GetArrayLength(ba);
	base::ByteVector* bvp = new base::ByteVector(size);
	bvp->reserve(reserve > size ? reserve : size); // Allow specification of larger reserve size, but ignore values smaller than length of array
	if (size == 0) return (jlong)bvp;
	env->GetByteArrayRegion(ba, 0, size, (jbyte*)&((*bvp)[0]));
	// message("DeleteLocalRef byteVectorNative ba");
	// env->DeleteLocalRef(ba);
	return (jlong)bvp;
    }
    
    // Copy between already allocated buffers, from->to.  Reallocate and return on too small.
    JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_copyNativebv2ba(JNIEnv* env, jobject obj, jlong bv, jbyteArray ba) {
	base::ByteVector* bvp = (base::ByteVector*)bv;
	long size = bvp->size();
	if (size > env->GetArrayLength(ba)) {
	    ba = env->NewByteArray(size);
	}
	// fprintf(stderr, "bv %ld, bvsize %ld, basize %ld\n", (long)bv, size, env->GetArrayLength(ba));
	env->SetByteArrayRegion(ba, 0, size, (const jbyte*)&((*bvp)[0]));
	return ba;
    }
    
    JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_copyNativebv2baRealloc(JNIEnv* env, jobject obj, jlong bv, jbyteArray ba) {
	base::ByteVector* bvp = (base::ByteVector*)bv;
	long size = bvp->size();
	if (size > env->GetArrayLength(ba)) {
	    message("DeleteLocalRef copyNativebv2baRealloc ba");
	    env->DeleteLocalRef(ba);
	    ba = env->NewByteArray(size);
	}
	// fprintf(stderr, "bv %ld, bvsize %ld, basize %ld\n", (long)bv, size, env->GetArrayLength(ba));
	env->SetByteArrayRegion(ba, 0, size, (const jbyte*)&((*bvp)[0]));
	return ba;
    }
    
    JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_copyNativeba2bp(JNIEnv* env, jobject obj, jbyteArray ba, jlong bp, jlong bpsize) {
	unsigned char* bpp = (unsigned char*)bp;
	long size = env->GetArrayLength(ba);
	if (size > bpsize) size = bpsize; // Use only output we have.
	env->GetByteArrayRegion(ba, 0, size, (jbyte*)bpp);
	// message("DeleteLocalRef copyNativeba2bp ba");
	// env->DeleteLocalRef(ba);
	return size;
    }
    
    JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_copyNativebp2ba(JNIEnv* env, jobject obj, jlong bp, jlong bpsize, jbyteArray ba) {
	unsigned char* bpp = (unsigned char*)bp;
	// fprintf(stderr, "ba: %p size: %ld, bp: %p\n", (void*)ba, (long)bpsize, (void*)bp);
	long asize = env->GetArrayLength(ba);
	long size = bpsize > asize ? asize:bpsize;
	if (bpp == NULL) {
	    error(bpsize, "copyNativebp2ba got NULL for bpp");
	}
	env->SetByteArrayRegion(ba, 0, size, (jbyte*)bpp);
	return size;
    }
    
    JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_copyNativebp2baRealloc(JNIEnv* env, jobject obj, jlong bp, jlong bpsize, jbyteArray ba) {
	unsigned char* bpp = (unsigned char*)bp;
	long size = bpsize;
	if (size > env->GetArrayLength(ba)) {
	    message("DeleteLocalRef copyNativebp2ba ba");
	    env->DeleteLocalRef(ba);
	    ba = env->NewByteArray(size);
	}
	env->SetByteArrayRegion(ba, 0, size, (jbyte*)bpp);
	return ba;
    }
    
    // Returning the ByteVector again isn't necessary, but symmetry, man, symmetry's the thing!!
    JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_copyNativeba2bv(JNIEnv* env, jobject obj, jbyteArray ba, jlong bv) {
	base::ByteVector* bvp = (base::ByteVector*)bv;
	long size = env->GetArrayLength(ba);
	bvp->reserve(size);
	// fprintf(stderr, "bv %ld, bvsize %ld, basize %ld\n", (long)bv, bvp->size(), size);
	env->GetByteArrayRegion(ba, 0, size, (jbyte*)&((*bvp)[0]));
	// message("DeleteLocalRef copyNativeba2bv ba");
	// env->DeleteLocalRef(ba);
	return (jlong)bvp;
    }
    
    JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_byteArrayNativebp(JNIEnv* env, jobject obj, jlong bp, jlong size) {
	void* bpp = (void*)bp;
        // fprintf(stderr, "byteArrayNativebp: size: %ld bpp: %p firstbyte: %hd\n", (long)size, bpp, *(unsigned char *)bpp);
	if (bp == 0L || size < 0) return 0L;
	jbyteArray ba = env->NewByteArray(size);
	env->SetByteArrayRegion(ba, 0, size, (const jbyte*)bpp);
	return ba;
    }
    
    JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_bytePointerNative(JNIEnv* env, jobject obj, jbyteArray ba, jlong size) {
	int basize = env->GetArrayLength(ba);
	size = basize < size ? basize : size;
	void* bpp = new unsigned char[size];
	env->GetByteArrayRegion(ba, 0, size, (jbyte*)bpp);
	// message("DeleteLocalRef bytePointerNative ba");
	// env->DeleteLocalRef(ba);
	return (jlong)bpp;
    }
    
#ifdef JNI_VERSION_1_4
#define JNI_VER JNI_VERSION_1_4
#endif
  // JDK 1.5 used JNI_VERSION 1.4!  But, just in case, keep it here.
#ifdef JNI_VERSION_1_5
#undef JNI_VER
#define JNI_VER JNI_VERSION_1_5
#endif
#ifdef JNI_VERSION_1_6
#undef JNI_VER
#define JNI_VER JNI_VERSION_1_6
#endif


    // We should have one of these so that we have access to newer JNI calls.
    // However, make sure there is only one...
    // See: http://android.wooyd.org/JNIExample/files/JNIExample.pdf
    // Although careful, object caching is out of date and not needed.
    JavaVM* gJavaVM = 0;
    JNIEXPORT jint JNICALL
    JNI_OnLoad (JavaVM * vm, void * reserved) {
	JNIEnv *env;
	gJavaVM = vm;
	if (vm->GetEnv((void**)&env, JNI_VER) != JNI_OK) {
	    // DOCORE_ERROR("Failed to get the environment using GetEnv() for JNI_VER");
	    return -1;
	}
	return JNI_VER;
    }
    
    /*
     * Convenience methods.
     *
     */
    
    // Simple helper to use global gJavaVM
    JNIEXPORT JNIEnv*
    Xbig_GetEnv() {
	JNIEnv* env;
	if (gJavaVM->GetEnv((void **)&env, JNI_VER)) {
	    // DOCORE_ERROR("Failed to get the environment using GetEnv() for JNI_VER");
	    return NULL;
	}
	return env;
    }
    // Need error checking / logging...
    JNIEXPORT jmethodID
    Xbig_cpath2MIDenv(JNIEnv* env, const char* cpath, const char* meth, const char* sig) {
	jclass cls = env->FindClass(cpath);
	if (!cls) {fprintf(stderr, "Class was 0 for: %s\n",  cpath); return 0;}
	jmethodID mid = env->GetMethodID(cls, meth, sig);
	// message("DeleteLocalRef class");
	env->DeleteLocalRef(cls);
	if (!mid) { fprintf(stderr, "MID was 0 for: %s\n",  meth); fflush(stderr); }
	return mid;
    }
    JNIEXPORT jmethodID
    Xbig_cpath2MID(const char* cpath, const char* meth, const char* sig) {
	JNIEnv* env = Xbig_GetEnv();
	return Xbig_cpath2MIDenv(env, cpath, meth, sig);
    }
    JNIEXPORT jfieldID
    Xbig_cpath2FIDenv(JNIEnv* env, const char* cpath, const char* field, const char* sig) {
	jclass cls = env->FindClass(cpath);
	if (!cls) {fprintf(stderr, "Class was 0 for: %s\n",  cpath); return 0;}
	jfieldID fid = env->GetFieldID(cls, field, sig);
	// message("DeleteLocalRef class");
	env->DeleteLocalRef(cls);
	if (!fid) { fprintf(stderr, "FID was 0 for: %s\n",  field); fflush(stderr); }
	return fid;
    }
    JNIEXPORT jmethodID
    Xbig_obj2MIDenv(JNIEnv* env, jobject obj, const char* meth, const char* sig) {
	jclass cls = env->GetObjectClass(obj);
	// message("DeleteLocalRef class");
	env->DeleteLocalRef(cls);
	jmethodID mid = env->GetMethodID(cls, meth, sig);
	return mid;
    }
    JNIEXPORT jmethodID
    Xbig_obj2MID(jobject obj, const char* meth, const char* sig) {
	JNIEnv* env = Xbig_GetEnv();
	return Xbig_obj2MIDenv(env, obj, meth, sig);
    }
    
    unsigned char test255before[4] = {0x55};
    unsigned char test255[255] = {0};
    unsigned char test255after[4] = {0xaa};
    JNIEXPORT jlong
    Java_org_javaglue_base_ByteArray_static255Native() {
	return (jlong)&test255;
    }
    JNIEXPORT jboolean
    Java_org_javaglue_base_ByteArray_static255badNative() {
	if (test255before[0] != 0x55 || test255after[0] != 0xaa) return true; else return false;
    }
#ifdef __cplusplus
}
#endif
