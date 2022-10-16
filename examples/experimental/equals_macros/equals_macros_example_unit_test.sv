module equals_macros_example_unit_test;

  import svunit_pkg::svunit_testcase;
  `include "svunit_defines.svh"

  string name = "equals_macros_example_ut";
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


  `SVTEST(fail_unless_equal__int_variables)
    int one = 1;
    int two = 2;
    `ASSERT_EQ(one, two, #(int));
  `SVTEST_END


  `SVTEST(fail_unless_equal__int_variable_and_int_constant)
    int one = 1;
    `ASSERT_EQ(one, 2, #(int));
  `SVTEST_END


  `SVTEST(fail_unless_equal__int_function_and_int_constant)
    `ASSERT_EQ(function_returning_one(), 2, #(int));
  `SVTEST_END


  `SVUNIT_TESTS_END


  function int function_returning_one();
    return 1;
  endfunction

endmodule
