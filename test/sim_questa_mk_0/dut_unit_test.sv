import svunit_pkg::*;

`include "dut.sv"
typedef class c_dut_unit_test;

module dut_unit_test;
  c_dut_unit_test unittest;
  string name = "dut_ut";

  function void setup();
    unittest = new(name);
  endfunction
endmodule

class c_dut_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  dut my_dut;


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
    my_dut = new(/* New arguments if needed */);
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


