module fail_macros_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "fail_macros_ut";
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

    `SVTEST(fail_if)
      if (1)
        `FAIL_IF(0)
      else
        $display("went into 'else' block");
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
