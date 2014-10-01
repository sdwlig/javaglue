#include <stdio.h>
#include <string.h>
#include <string>
#include <vector>
#include <jni.h>
#include "basedelete.h"
#include "jni_base.h"

class test {
 public:
  int x;
  float y;
  char *p;
  test();
  test(char *pp);
};

