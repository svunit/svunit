package fibonacci_test;

  import fibonacci::*;

  `include "svunit.svh"
  `include "svunit_defines.svh"


  `TEST_BEGIN(fibonacci_0)
    `FAIL_UNLESS(fibonacci(0) == 0);
  `TEST_END

  `TEST_BEGIN(fibonacci_1)
    `FAIL_UNLESS(fibonacci(1) == 1);
  `TEST_END

  `TEST_BEGIN(fibonacci_2)
    `FAIL_UNLESS(fibonacci(2) == 1);
  `TEST_END

  `TEST_BEGIN(fibonacci_3)
    `FAIL_UNLESS(fibonacci(3) == 2);
  `TEST_END

  `TEST_BEGIN(fibonacci_4)
    `FAIL_UNLESS(fibonacci(4) == 3);
  `TEST_END

  `TEST_BEGIN(fibonacci_5)
    `FAIL_UNLESS(fibonacci(5) == 5);
  `TEST_END

  `TEST_BEGIN(fibonacci_6)
    `FAIL_UNLESS(fibonacci(6) == 8);
  `TEST_END

  `TEST_BEGIN(fibonacci_7)
    `FAIL_UNLESS(fibonacci(7) == 13);
  `TEST_END

  `TEST_BEGIN(fibonacci_8)
    `FAIL_UNLESS(fibonacci(8) == 21);
  `TEST_END

  `TEST_BEGIN(fibonacci_9)
    `FAIL_UNLESS(fibonacci(9) == 34);
  `TEST_END

  `TEST_BEGIN(fibonacci_10)
    `FAIL_UNLESS(fibonacci(10) == 55);
  `TEST_END

endpackage
