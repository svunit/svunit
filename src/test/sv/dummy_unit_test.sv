module dummy_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "dummy_ut";
  svunit_testcase svunit_ut;


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

    `SVTEST(some_passing_test)
      `FAIL_UNLESS(svunit_under_test::TRUE)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
