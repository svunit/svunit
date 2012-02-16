import svunit_pkg::*;

`include "svunit_defines.svh"
`include "dut.sv"
typedef class c_dut_unit_test;

module dut_unit_test;
  c_dut_unit_test unittest;
  string name = "dut_ut";

  dut my_dut();

  function void setup();
    unittest = new(name, my_dut);
  endfunction
endmodule

class c_dut_unit_test extends svunit_testcase;

  virtual dut my_dut;

  //===================================
  // Constructor
  //===================================
  function new(string name,
               virtual dut my_dut);
    super.new(name);

    this.my_dut = my_dut;
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


