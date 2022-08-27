
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
    `FAIL_UNLESS_EQUAL(one, two);
  `SVTEST_END


  `SVTEST(fail_unless_equal__int_variable_and_int_constant)
    int one = 1;
    `FAIL_UNLESS_EQUAL(one, 2);
  `SVTEST_END


  `SVTEST(fail_unless_equal__int_function_and_int_constant)
    `FAIL_UNLESS_EQUAL(function_returning_one(), 2);
  `SVTEST_END


  `SVTEST(fail_if_equal__int_variables)
    int one = 1;
    int also_one = 1;
    `FAIL_IF_EQUAL(one, also_one);
  `SVTEST_END


  `SVTEST(fail_unless_equal__int_arrays)
    int some_array[] = '{ 1, 2, 3 };
    int first_three_primes[] = '{ 2, 3, 5 };
    `FAIL_UNLESS_EQUAL(some_array, first_three_primes);
  `SVTEST_END


  `SVTEST(fail_unless_equal__bit_vectors_displayed_as_hex)
    bit[15:0] val1 = 'hdead;
    bit[15:0] val2 = 'hbeef;
    `FAIL_UNLESS_EQUAL(val1, val2, "'h%x");
  `SVTEST_END


  `SVTEST(fail_if_equal__bit_vectors_displayed_as_hex)
    bit[15:0] val1 = 'hbeef;
    bit[15:0] val2 = 'hbeef;
    `FAIL_IF_EQUAL(val1, val2, "'h%x");
  `SVTEST_END


  `SVUNIT_TESTS_END


  function int function_returning_one();
    return 1;
  endfunction

endmodule
