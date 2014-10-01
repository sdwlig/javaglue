#include "test.h"

test::test() { puts("class test instance created."); p = NULL; }
test::test(char *pp) { p = pp; }
