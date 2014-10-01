#include <stdio.h>
#include <string.h>
#include <string>
#include <vector>
#include <jni.h>
#include <stdint.h>
#include "basedelete.h"
#include "jni_base.h"

enum EnumTest {
  First=0,Second,Third
};

class Test00 {
  int x;
  float f;
  std::string s;
};

class Test0 {
   public:
   enum EnumTest et;
   Test00 t;
   int i;
   Test0() { i = 100; }
   void getet(enum EnumTest& et_) { et_ = et; }
   void getetp(enum EnumTest* et_) { *et_ = et; }
   Test0(int ip) { i = ip; }
   void setrefi(int& desti) { desti = i; }
};

// typedef std::vector<unsigned char> ByteVector; Get this from modified Xbig now.
class Test {
 public:
  char *p;
  char **pp;
  // char ***ppp; // Only pointers to pointers are handled so far.
  char ** cpTocpp(char*& cp) { return &cp; }

  unsigned char *up;
  unsigned char **upp;
  // unsigned char ***uppp; // Only pointers to pointers are handled so far.
  unsigned char ** upToupp(unsigned char*& cp) { return &cp; }

  uint8_t u8;
  uint8_t* u8p;
  uint8_t** u8pp;

  int8_t i8;
  int8_t* i8p;
  int8_t** i8pp;

  uint8_t** u8pTopp(uint8_t*& u8) { return &u8; }

  unsigned short ushort;
  unsigned short* ushortp;
  unsigned short** ushortpp;
  unsigned short** ushortTopp(unsigned short*& up) { return &up; }
  
  short ishort;
  short* ishortp;
  short** ishortpp;
  short** ishortTopp(short*& up) { return &up; }
  
  uint16_t u16;
  uint16_t* u16p;
  uint16_t** u16pp;
  uint16_t** u16Topp(uint16_t*& up) { return &up; }
  
  int16_t i16;
  int16_t* i16p;
  int16_t** i16pp;
  int16_t** i16Topp(int16_t*& up) { return &up; }
  
  uint32_t u32;
  uint32_t* u32p;
  uint32_t** u32pp;
  uint32_t** u32Topp(uint32_t*& up) { return &up; }
  
  int32_t i32;
  int32_t* i32p;
  int32_t** i32pp;
  int32_t** i32Topp(int32_t*& up) { return &up; }
  
  uint64_t u64;
  uint64_t* u64p;
  uint64_t** u64pp;
  uint64_t** u64Topp(uint64_t*& up) { return &up; }
  
  int64_t i64;
  int64_t* i64p;
  int64_t** i64pp;
  int64_t** i64Topp(int64_t*& up) { return &up; }
  

  int testints() {
    u8 = 5;
    i8 = 6;
    return i8;
  }

  int x;
  float y;
  Test();
  Test(char *pp);
  bool isNullFlag;
  char * doWhatever(char *pp) { if (pp == NULL) isNullFlag = true; else isNullFlag = false; return pp; }
  std::string * mkStringP(std::string s) { return new std::string(s); }
  std::string toString(char* pp) { std::string s(pp); return s; }
  void setString(std::string s) { p = strdup(s.c_str()); }
  void setStringP(std::string *s) { p = strdup(s->c_str()); delete s; }
  std::string getString() { return std::string(p); }
  char *getCString() { return p; }
  char *dupcString(std::string s) { return strdup(s.c_str()); }
  bool isNull() { return isNullFlag; }
  bool isTestNull(Test *tt) {
    if (tt == NULL) isNullFlag = true; else isNullFlag = false; return isNullFlag;
  }
  bool isTest(Test tt) {
    // if (tt == NULL) isNullFlag = true; else isNullFlag = false; return isNullFlag;
    return false;
  }
  Test* getTest() { return this; }
  Test* getTestNull() { return (Test*)NULL; }
  static base::ByteVector& mkByteVector() {
    base::ByteVector* bp = new base::ByteVector(20);
    (*bp)[0] = 'h'; (*bp)[1] = 'i';
    return *bp;
  }
  Test0 t0;
  Test0 getTest0() { return t0; }

  // std::wstring ws;
  // std::wstring getWString() { return ws; }

  static void bvDouble(base::ByteVector, base::ByteVector) {
    
  }

};

class EnumTestPtr {
 public:
  enum EnumTest et;
  enum EnumTest get() { return et; }
  void set(enum EnumTest et_) { et = et_; }
  enum EnumTest* addr() { return &et; }
  int getInt() { return (int)et; }
  void set(int i) { et = (EnumTest)i; }
};

class Test2 {
   public:
   enum EnumTest et;
   Test t;
   int i;
   Test2();
   void getet(enum EnumTest& et_) { et_ = et; }
   void getetp(enum EnumTest* et_) { *et_ = et; }
   Test2(int ip);
   void setrefi(int& desti) { desti = i; }
};

class Test3 {
  int j;
  void* p3;
 public:
  Test3();
  void* getP3() { return p3; }
};

class Test4: public Test, public Test3 {
 public:
  Test4() { }

};

// std::vector<unsigned char>* byteVector(jbyteArray jba);
// jbyteArray byteArray(JNIEnv* env, std::vector<unsigned char>);
