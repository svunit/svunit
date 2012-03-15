import svunit_pkg::*;

`include "svunit_defines.svh"
`include "test.sv.abc"
typedef class c_test_unit_test;

module test_unit_test;
  c_test_unit_test unittest;
  string name = "test_ut";

  function void setup();
    unittest = new(name);
  endfunction
endmodule

class c_test_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  test my_test;


  //===================================
  // Constructor
  //===================================
  function new(string name);
    super.new(name);

    my_test = new(/* New arguments if needed */);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    super.setup();
    /* Place Setup Code Here */
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    super.teardown();
    /* Place Teardown Code Here */
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END(_NAME_)
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END(mytest)
  //===================================
  `SVUNIT_TESTS_BEGIN



  `SVUNIT_TESTS_END

endclass


