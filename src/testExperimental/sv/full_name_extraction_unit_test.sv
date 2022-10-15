module full_name_extraction_unit_test;

  import svunit_stable_pkg::*;
  `include "svunit_stable_defines.svh"

  string name = "full_name_extraction_ut";
  svunit_testcase svunit_ut;


  import svunit::full_name_extraction;

  full_name_extraction full_name_extr = new();


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
