import svunit_pkg::*;

`include "svunit_defines.svh"
`include "dut.sv"
typedef class c_dut_unit_test;

interface dut_unit_test_if;
endinterface

module dut_unit_test;
  c_dut_unit_test unittest;
  string name = "dut_ut";

  dut my_dut();
  dut_unit_test_if my_dut_if();

  function void setup();
    unittest = new(name, my_dut_if);
  endfunction
endmodule

class c_dut_unit_test extends svunit_testcase;

  virtual dut_unit_test_if my_dut_if;

  //===================================
  // Constructor
  //===================================
  function new(string name,
               virtual dut_unit_test_if my_dut_if);
    super.new(name);

    this.my_dut_if = my_dut_if;
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


