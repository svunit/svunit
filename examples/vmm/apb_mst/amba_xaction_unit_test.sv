import svunit_pkg::*;

`include "amba_xaction.sv"
typedef class c_amba_xaction_unit_test;

module amba_xaction_unit_test;
  c_amba_xaction_unit_test unittest;
  string name = "amba_xaction_ut";

  function void setup();
    unittest = new(name);
  endfunction
endmodule

class c_amba_xaction_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  amba_xaction my_amba_xaction;


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
    my_amba_xaction = new(/* New arguments if needed */);
    /* Place Setup Code Here */
  endtask


  //===================================
  // This is where we run all the Unit
  // Tests
  //===================================
  task run_test();
    super.run_test();
    `INFO("Running Unit Tests for class: amba_xaction:");
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


