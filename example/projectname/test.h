#include <stdio.h>
#include <string.h>
#include <string>
#include <vector>
#include <jni.h>
#include "basedelete.h"
#include "jni_base.h"

// typedef std::vector<unsigned char> ByteVector; Get this from modified Xbig now.
class test {
 public:
  int x;
  float y;
  char *p;
  test();
  test(char *pp);
  bool isNullFlag;
  char * doWhatever(char *pp) { if (pp == NULL) isNullFlag = true; else isNullFlag = false; return pp; }
  std::string * mkStringP(std::string s) { return new std::string(s); }
  void setString(std::string s) { p = strdup(s.c_str()); }
  void setStringP(std::string *s) { p = strdup(s->c_str()); delete s; }
  std::string getString() { return std::string(p); }
  char *getCString() { return p; }
  char *dupcString(std::string s) { return strdup(s.c_str()); }
  bool isNull() { return isNullFlag; }
  bool isTestNull(test *tt) {
    if (tt == NULL) isNullFlag = true; else isNullFlag = false; return isNullFlag;
  }
  bool isTest(test tt) {
    // if (tt == NULL) isNullFlag = true; else isNullFlag = false; return isNullFlag;
    return false;
  }
  test* getTest() { return this; }
  test* getTestNull() { return (test*)NULL; }
  static base::ByteVector& mkByteVector() {
    base::ByteVector* bp = new base::ByteVector(20);
    (*bp)[0] = 'h'; (*bp)[1] = 'i';
    return *bp;
  }

  // std::wstring ws;
  // std::wstring getWString() { return ws; }

  static void bvDouble(base::ByteVector, base::ByteVector) {
    
  }

};

enum tenum {
  one, two, three;
};

class test2 {
   public:
   test t;
   int i;
   test2();
   test2(int ip);
   tenum tel;
   void in(tenum te) { tel = te; }
   void out(tenum& te) { te = three; }
};

class test3 {
  int j;
  void* p3;
 public:
  test3();
  void* getP3() { return p3; }
};

class test4: public test, public test3 {
 public:
  test4() { }

};

// std::vector<unsigned char>* byteVector(jbyteArray jba);
// jbyteArray byteArray(JNIEnv* env, std::vector<unsigned char>);
