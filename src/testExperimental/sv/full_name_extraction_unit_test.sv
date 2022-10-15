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

    `SVTEST(test_defined_directly_under_package)
      `FAIL_UNLESS_STR_EQUAL(
          full_name_extr.get_full_name("tests::some_test extends svunit::test"),
          "tests.some_test")
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
