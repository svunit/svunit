package factorial_test;

  import factorial::*;

  `include "svunit.svh"


  `TEST_BEGIN(handles_zero_input)
  //   `FAIL_UNLESS(factorial(0) == 1)
  `TEST_END


  `TEST_BEGIN(handle_positive_input)
  //   `FAIL_UNLESS(factorial(1) == 1)
  //   `FAIL_UNLESS(factorial(2) == 2)
  //   `FAIL_UNLESS(factorial(3) == 6)
  //   `FAIL_UNLESS(factorial(8) == 40320)
  `TEST_END

endpackage
