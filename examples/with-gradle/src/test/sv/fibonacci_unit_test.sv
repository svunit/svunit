module fibonacci_unit_test;
  import svunit_pkg::svunit_testcase;
  `include "svunit_defines.svh"

  string name = "fibonacci_ut";
  svunit_testcase svunit_ut;


  import fibonacci::*;


  function void build();
    svunit_ut = new(name);
  endfunction


  task setup();
    svunit_ut.setup();
  endtask


  task teardown();
    svunit_ut.teardown();
  endtask


  `SVUNIT_TESTS_BEGIN

    `SVTEST(fibonacci_0)
      `FAIL_UNLESS(fibonacci(0) == 0);
    `SVTEST_END

    `SVTEST(fibonacci_1)
      `FAIL_UNLESS(fibonacci(1) == 1);
    `SVTEST_END

    `SVTEST(fibonacci_2)
      `FAIL_UNLESS(fibonacci(2) == 1);
    `SVTEST_END

    `SVTEST(fibonacci_3)
      `FAIL_UNLESS(fibonacci(3) == 2);
    `SVTEST_END

    `SVTEST(fibonacci_4)
      `FAIL_UNLESS(fibonacci(4) == 3);
    `SVTEST_END

    `SVTEST(fibonacci_5)
      `FAIL_UNLESS(fibonacci(5) == 5);
    `SVTEST_END

    `SVTEST(fibonacci_6)
      `FAIL_UNLESS(fibonacci(6) == 8);
    `SVTEST_END

    `SVTEST(fibonacci_7)
      `FAIL_UNLESS(fibonacci(7) == 13);
    `SVTEST_END

    `SVTEST(fibonacci_8)
      `FAIL_UNLESS(fibonacci(8) == 21);
    `SVTEST_END

    `SVTEST(fibonacci_9)
      `FAIL_UNLESS(fibonacci(9) == 34);
    `SVTEST_END

    `SVTEST(fibonacci_10)
      `FAIL_UNLESS(fibonacci(10) == 55);
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
