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


  const string else_block_error_msg = "went into 'else' block";


  `SVUNIT_TESTS_BEGIN

    `SVTEST(fail_if_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_IF(0)
      else
        $display(else_block_error_msg);
    `SVTEST_END


    `SVTEST(fail_if_log_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_IF_LOG(0, "dummy")
      else
        $display(else_block_error_msg);
    `SVTEST_END


    `SVTEST(fail_if_equal_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_IF_EQUAL(0, 1)
      else
        $display(else_block_error_msg);
    `SVTEST_END


    `SVTEST(fail_unless_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_UNLESS(1)
      else
        $display(else_block_error_msg);
    `SVTEST_END


    `SVTEST(fail_unless_log_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_UNLESS_LOG(1, "dummy")
      else
        $display(else_block_error_msg);
    `SVTEST_END


    `SVTEST(fail_unless_equal_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_UNLESS_EQUAL(0, 0)
      else
        $display(else_block_error_msg);
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
