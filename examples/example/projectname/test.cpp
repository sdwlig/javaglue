#include <projectname/test.h>

Test::Test() { puts("class Test instance created."); p = NULL; }
Test::Test(char *pp) { p = pp; }
Test2::Test2() {
  i = 55;
}
Test2::Test2(int ip) {
     i=ip;
}
Test3::Test3() { p3 = 0; }
