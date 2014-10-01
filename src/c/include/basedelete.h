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

/**
 * This file defines types that are added to the Javaglue inputs so that certain types are available for usage in interfaces.
 */

#ifndef _Included_javaglue_basedelete_h
#define _Included_javaglue_basedelete_h

#include <stdint.h>
#include <jni.h>
#include <string>
#include <vector>
#include <map>

namespace base { // Some commonly needed template types.
typedef std::vector<unsigned char> ByteVector;
typedef std::vector<std::string> StringVector;
typedef std::vector<ByteVector> VectorByteVector;
typedef std::map<std::string, ByteVector> MapStringByteVector;
typedef std::map<long, ByteVector> MapLongByteVector;
typedef std::map<std::string, std::string> MapStringString;
}

/**
 * Single scalar classes.  Makes it easy to create local C++ variables in Java/Javascript/Groovy.
 * By supporting addr(), a typed pointer is available for pointer and reference types parameter usage.
 */
class VarChar {
 public:
  VarChar() { val = 0; }
  VarChar(char c) { val = c; }
  char val;
  char* addr() { return &val; }
};

class VarUChar {
 public:
  VarUChar() { val = 0; }
  VarUChar(unsigned char c) { val = c; }
  unsigned char val;
  unsigned char* addr() { return &val; }
};

class VarInt {
 public:
  VarInt() { val = 0; }
  VarInt(int i) { val = i; }
  int val;
  int* addr() { return &val; }
};

class VarUInt {
 public:
  VarUInt() { val = 0; }
  VarUInt(unsigned int i) { val = i; }
  unsigned int val;
  unsigned int* addr() { return &val; }
};


class VarInt8 {
 public:
  VarInt8() { val = 0; }
  VarInt8(int8_t i) { val = i; }
  int8_t val;
  int8_t* addr() { return &val; }
};

class VarUInt8 {
 public:
  VarUInt8() { val = 0; }
  VarUInt8(uint8_t i) { val = i; }
  uint8_t val;
  uint8_t* addr() { return &val; }
};

class VarInt16 {
 public:
  VarInt16() { val = 0; }
  VarInt16(int16_t i) { val = i; }
  int16_t val;
  int16_t* addr() { return &val; }
};

class VarUInt16 {
 public:
  VarUInt16() { val = 0; }
  VarUInt16(uint16_t i) { val = i; }
  uint16_t val;
  uint16_t* addr() { return &val; }
};

class VarInt32 {
 public:
  VarInt32() { val = 0; }
  VarInt32(int32_t i) { val = i; }
  int32_t val;
  int32_t* addr() { return &val; }
};

class VarUInt32 {
 public:
  VarUInt32() { val = 0; }
  VarUInt32(uint32_t i) { val = i; }
  uint32_t val;
  uint32_t* addr() { return &val; }
};

class VarInt64 {
 public:
  VarInt64() { val = 0; }
  VarInt64(int64_t i) { val = i; }
  int64_t val;
  int64_t* addr() { return &val; }
};

class VarFloat {
 public:
  VarFloat() { val = 0; }
  VarFloat(float i) { val = i; }
  float val;
  float* addr() { return &val; }
};

class VarDouble {
 public:
  VarDouble() { val = 0; }
  VarDouble(double i) { val = i; }
  double val;
  double* addr() { return &val; }
};

/**
 * Provides an easy way to new/delete arrays of scalar types.
 */
class Scalar {
 public:
  // static signed int8_t* newsint8(int count) { return new signed int8_t[count]; }
  static int8_t* newint8(int count) { return new int8_t[count]; }
  static uint8_t* newuint8(int count) { return new uint8_t[count]; }
  // static signed int16_t* newsint16(int count) { return new signed int16_t[count]; }
  static int16_t* newint16(int count) { return new int16_t[count]; }
  static uint16_t* newuint16(int count) { return new uint16_t[count]; }
  static int32_t* newint32(int count) { return new int32_t[count]; }
  static uint32_t* newuint32(int count) { return new uint32_t[count]; }
  static int64_t* newint64(int count) { return new int64_t[count]; }
  static uint64_t* newuint64(int count) { return new uint64_t[count]; }
  static float* newfloat(int count) { return new float[count]; }
  static double* newdouble(int count) { return new double[count]; }

  //static char* addr(char& p) { return &p; }
  //static unsigned char* addr(unsigned char& p) { return &p; }
  //static short* addr(short& p) { return &p; }
  //static unsigned short* addr(unsigned short& p) { return &p; }
  //static int* addr(int& p) { return &p; }
  //static unsigned int* addr(unsigned int& p) { return &p; }
  //static long* addr(long& p) { return &p; }

  // This doesn't work because accessing a scalar member variable always results in a value, not a reference.
  // static int8_t* addr(int8_t& p) { return &p; }
  // static uint8_t* addr(uint8_t& p) { return &p; }
  // static int16_t* addr(int16_t& p) { return &p; }
  // static uint16_t* addr(uint16_t& p) { return &p; }
  // static int32_t* addr(int32_t& p) { return &p; }
  // static uint32_t* addr(uint32_t& p) { return &p; }
  // static int64_t* addr(int64_t& p) { return &p; }
  // static uint64_t* addr(uint64_t& p) { return &p; }

  // static void delete(signed int8_t* p) { delete p; }
  static void del(int8_t* p) { delete p; }
  static void del(uint8_t* p) { delete p; }
  // static void delete(signed int16_t* p) { delete p; }
  static void del(int16_t* p) { delete p; }
  static void del(uint16_t* p) { delete p; }
  static void del(int32_t* p) { delete p; }
  static void del(uint32_t* p) { delete p; }
  static void del(int64_t* p) { delete p; }
  // Broken method name mangling right now:
  // static void del(uint64_t* p) { delete p; }
  static void del(float* p) { delete p; }
  static void del(double* p) { delete p; }
};
class Delete {
  public:
  static void byteVector(base::ByteVector* bv);
  static void stringVector(base::StringVector* sv);
  static void vectorByteVector(base::VectorByteVector* vbv);
  static void mapStringByteVector(base::MapStringByteVector* msbv);
  static void mapLongByteVector(base::MapLongByteVector* mlbv);
  static void mapStringString(base::MapStringString* mss);
};

// See jni_base.h for JNIEXPORTs
#endif // _Included_javaglue_basedelete_h
