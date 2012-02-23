import svunit_pkg::*;

`include "svunit_defines.svh"
`include "apb_coverage.sv"
typedef class c_apb_coverage_unit_test;

module apb_coverage_unit_test;
  c_apb_coverage_unit_test unittest;
  string name = "apb_coverage_ut";

  function void setup();
    unittest = new(name);
  endfunction
endmodule

class c_apb_coverage_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  apb_coverage my_apb_coverage;


  //===================================
  // Constructor
  //===================================
  function new(string name);
    super.new(name);

    my_apb_coverage = new({ name , "::my_apb_coverage" }, null);
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


