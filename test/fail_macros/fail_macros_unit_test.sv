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

    `SVTEST(fail_if_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_IF(0)
      else
        $display("went into 'else' block");
    `SVTEST_END


    `SVTEST(fail_if_log_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_IF_LOG(0, "dummy")
      else
        $display("went into 'else' block");
    `SVTEST_END


    `SVTEST(fail_if_equal_macro_under_if_statement_with_else_block)
      if (1)
        `FAIL_IF_EQUAL(0, 1)
      else
        $display("went into 'else' block");
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
