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
    // this should have the "running" and "pass" logged
    `SVTEST(first_test)
    `SVTEST_END(first_test)


    // this should have the "running" and "fail" logged w/1 error
    `SVTEST(second_test)
      `FAIL_IF(1);
    `SVTEST_END(second_test)


    // this should have the "running" and "fail" logged w/1 error
    `SVTEST(third_test)
      int beam = 1;
      `FAIL_IF(beam == 1);
      `FAIL_IF(beam != 2);
    `SVTEST_END(third_test)

  `SVUNIT_TESTS_END

endclass


