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


#ifndef _Included_jni_base_
#define _Included_jni_base_

#include <jni.h>
#include <string>
#include <vector>


#ifdef WIN32
	#define EXPORT __declspec(dllexport)
#else
	#define EXPORT
#endif


namespace org { namespace javaglue { namespace jni {

EXPORT std::string& to_stdstring(JNIEnv* env, jstring jString, std::string& outString);

EXPORT std::string& to_stdstringUTF8(JNIEnv* env, jstring jString, std::string& outString);

EXPORT char* to_cstring(JNIEnv* env, jstring jString, char* outString);

EXPORT jstring to_jstring(JNIEnv* env, const std::string& str);

EXPORT jstring to_jstring(JNIEnv* env, const char*);

EXPORT jsize getStringLength(JNIEnv* env, const jstring& jString);

}}}

#ifdef __cplusplus
extern "C" {
#endif

  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_memsetByteVectorNative(JNIEnv* env, jobject obj, jlong bv, jlong b, jlong len);
  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_memsetBytePointerNative(JNIEnv* env, jobject obj, jlong bp, jlong b, jlong len);

  // org.javaglue.std.Ivector< Byte > byteVector   long bv = byteVector.getInstancePointer.pointer();
  JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_byteArrayNative(JNIEnv* env, jobject obj, jlong bv, jboolean fullAllocation);
  JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_byteArrayDirect(JNIEnv* env, jlong bv, jboolean fullAllocation);
  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_byteVectorNative(JNIEnv* env, jobject obj, jbyteArray ba, jlong reserve);
  JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_copyNativebv2ba(JNIEnv* env, jobject obj, jlong bv, jbyteArray ba);
  JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_copyNativebv2baRealloc(JNIEnv* env, jobject obj, jlong bv, jbyteArray ba);
  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_copyNativeba2bp(JNIEnv* env, jobject obj, jbyteArray ba, jlong bp, jlong bpsize);
  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_copyNativebp2ba(JNIEnv* env, jobject obj, jlong bp, jlong bpsize, jbyteArray ba);
  JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_copyNativebp2baRealloc(JNIEnv* env, jobject obj, jlong bp, jlong bpsize, jbyteArray ba);
  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_copyNativeba2bv(JNIEnv* env, jobject obj, jbyteArray ba, jlong bv);
  JNIEXPORT jbyteArray JNICALL Java_org_javaglue_base_ByteArray_byteArrayNativebp(JNIEnv* env, jobject obj, jlong bp, jlong size);
  JNIEXPORT jlong JNICALL Java_org_javaglue_base_ByteArray_bytePointerNative(JNIEnv* env, jobject obj, jbyteArray ba, jlong size);
  extern JNIEXPORT JavaVM* gJavaVM;
  extern JNIEXPORT JNIEnv* Javaglue_GetEnv();
  extern JNIEXPORT jmethodID Javaglue_cpath2MID(const char* cpath, const char* meth, const char* sig);
  extern JNIEXPORT jmethodID Javaglue_cpath2MIDenv(JNIEnv* env, const char* cpath, const char* meth, const char* sig);
  extern JNIEXPORT jfieldID Javaglue_cpath2FIDenv(JNIEnv* env, const char* cpath, const char* field, const char* sig);
  extern JNIEXPORT jmethodID Javaglue_obj2MID(jobject obj, const char* meth, const char* sig);
  extern JNIEXPORT jmethodID Javaglue_obj2MIDenv(JNIEnv* env, jobject obj, const char* meth, const char* sig);

#ifdef __cplusplus
}
#endif
#endif

