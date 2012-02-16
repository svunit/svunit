import svunit_pkg::*;

`include "svunit_defines.svh"
`include "test_if.sv"
typedef class c_test_if_unit_test;

module test_if_unit_test;
  c_test_if_unit_test unittest;
  string name = "test_if_ut";

  test_if my_test_if();

  function void setup();
    unittest = new(name, my_test_if);
  endfunction
endmodule

class c_test_if_unit_test extends svunit_testcase;

  virtual test_if my_test_if;

  //===================================
  // Constructor
  //===================================
  function new(string name,
               virtual test_if my_test_if);
    super.new(name);

    this.my_test_if = my_test_if;
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
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


