module test_registry_unit_test;

  import svunit_stable_pkg::*;
  `include "svunit_stable_defines.svh"

  string name = "test_registry_ut";
  svunit_testcase svunit_ut;


  import svunit::test_registry;


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

    `SVTEST(dummy)
      `FAIL_IF(1)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
