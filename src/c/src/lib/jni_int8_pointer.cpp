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
#include <stdint.h>
#include <jni_char_pointer.h>

/*
 * Class:     base_int8Pointer
 * Method:    _create
 * Signature: ()J
 */
JNIEXPORT jlong JNICALL Java_org_javaglue_base_int8Pointer__1create
  (JNIEnv *env, jclass that, jchar value)
{
	int8_t * ptr = new int8_t;
	*ptr = value;
	return reinterpret_cast<jlong>(ptr);
}

/*
 * Class:     base_int8Pointer
 * Method:    _dispose
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_org_javaglue_base_int8Pointer__1dispose
  (JNIEnv *env, jobject that, jlong pInstance)
{
	int8_t * ptr = reinterpret_cast<int8_t*>(pInstance);
	delete ptr;
}

/*
 * Class:     base_int8Pointer
 * Method:    _get
 * Signature: (J)C
 */
JNIEXPORT jchar JNICALL Java_org_javaglue_base_int8Pointer__1get
  (JNIEnv *env, jobject that, jlong pInstance)
{
	int8_t * ptr = reinterpret_cast<int8_t*>(pInstance);
	return * ptr;
}

/*
 * Class:     base_int8Pointer
 * Method:    _next
 * Signature: (J)J
 */
JNIEXPORT jlong JNICALL Java_org_javaglue_base_int8Pointer__1next
  (JNIEnv *env, jobject that, jlong pInstance)
{
	int8_t * ptr = reinterpret_cast<int8_t*>(pInstance);
	ptr++;
	return reinterpret_cast<jlong>(ptr);
}

/*
 * Class:     base_int8Pointer
 * Method:    _set
 * Signature: (JD)V
 */
JNIEXPORT void JNICALL Java_org_javaglue_base_int8Pointer__1set
  (JNIEnv *env, jobject that, jlong pInstance, jchar value)
{
	int8_t * ptr = reinterpret_cast<int8_t*>(pInstance);
	*ptr = value;
}
