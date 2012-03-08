import svunit_pkg::*;

`include "svunit_defines.svh"
`include "test-hij.sv"
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
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    my_test = new(/* New arguments if needed */);
    /* Place Setup Code Here */
  endtask


  //===================================
  // This is where we run all the Unit
  // Tests
  //===================================
  task run_test();
    super.run_test();

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    super.teardown();
    /* Place Teardown Code Here */
  endtask

endclass


