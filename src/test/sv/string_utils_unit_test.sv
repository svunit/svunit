module string_utils_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "string_utils_ut";
  svunit_testcase svunit_ut;

  import svunit_under_test::string_utils;


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

    `SVTEST(can_split_string_by_underscore)
      string some_string = "some_string";
      string parts[] = string_utils::split_by_char("_", some_string);
      string exp_parts[] = '{ "some", "string" };
      `FAIL_UNLESS_EQUAL(parts, exp_parts)
    `SVTEST_END


    `SVTEST(split_string_by_underscore_does_nothing_when_no_underscore)
      string some_string = "string";
      string parts[] = string_utils::split_by_char("_", some_string);
      string exp_parts[] = '{ "string" };
      `FAIL_UNLESS_EQUAL(parts, exp_parts)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
