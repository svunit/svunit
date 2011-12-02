import svunit_pkg::*;

`include "apb_bfm.sv"
typedef class c_apb_bfm_unit_test;

module apb_bfm_unit_test;
  c_apb_bfm_unit_test unittest;
  string name = "apb_bfm_ut";

  function void setup();
    unittest = new(name);
  endfunction
endmodule

class c_apb_bfm_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  apb_bfm my_apb_bfm;
  vmm_channel #(amba_xaction) inbox;


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
    my_apb_bfm = new("my_apb_bfm", "", -1,
                     inbox);
    /* Place Setup Code Here */
  endtask


  //===================================
  // This is where we run all the Unit
  // Tests
  //===================================
  task run_test();
    super.run_test();
    `INFO("Running Unit Tests for class: apb_bfm:");
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    super.teardown();
    /* Place Teardown Code Here */
  endtask

  `SVUNIT_TESTS_BEGIN

  `SVTEST(push_cmd_test)
    `FAIL_IF(my_apb_bfm.cmd_inbox == null);
  `SVTEST_END(push_cmd_test)

  `SVUNIT_TESTS_END

endclass


