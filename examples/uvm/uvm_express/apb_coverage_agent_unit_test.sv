`include "svunit_defines.svh"
`include "apb_coverage_agent.sv"
`include "apb_if.sv"

module apb_coverage_agent_unit_test;
  import svunit_pkg::svunit_testcase;
  import svunit_uvm_mock_pkg::*;

  string name = "apb_coverage_agent_ut";
  svunit_testcase svunit_ut;

  logic clk;
  initial begin
    clk = 1;
    forever #`CLK_PERIOD clk = ~clk;
  end

  apb_if bfm(.clk(clk));
  virtual apb_if.mstr bfm_mstr;

  //===================================
  // This is the UUT that we're
  // running the Unit Tests on
  //===================================
  apb_coverage_agent my_apb_coverage_agent;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    bfm_mstr = bfm;

    my_apb_coverage_agent = new({ name , "::my_apb_coverage_agent" }, null);
    uvm_config_db#(virtual apb_if.passive_slv)::
      set( uvm_root::get(), { name , "::my_apb_coverage_agent" }, "bfm", bfm);

    //-----------------------
    // deactivate by default
    //-----------------------
    svunit_deactivate_uvm_component(my_apb_coverage_agent);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();

    //----------------------
    // activate for testing
    //----------------------
    svunit_activate_uvm_component(my_apb_coverage_agent);

    bfm_mstr.async_reset();

    //---------------------
    // start the component
    //---------------------
    svunit_uvm_test_start();
  endtask


  //===================================
  // Here we deconstruct anything we
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();

    //--------------------
    // stop the component
    //--------------------
    svunit_uvm_test_finish();

    //---------------------------------------
    // deactivate at the end of unit testing
    //---------------------------------------
    svunit_deactivate_uvm_component(my_apb_coverage_agent);
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

  //-------------------------------------
  // Test: members_not_null
  //
  // verify the bfm, monitor and coverage
  // are all present
  //-------------------------------------
  `SVTEST(members_not_null)

    `FAIL_IF(my_apb_coverage_agent.bfm == null);
    `FAIL_IF(my_apb_coverage_agent.monitor == null);
    `FAIL_IF(my_apb_coverage_agent.coverage == null);
    `FAIL_IF(my_apb_coverage_agent.monitor.bfm == null);

  `SVTEST_END

  //---------------------------------------
  // Test: connectivity
  //
  // do a write and make sure the coverage
  // model is sampled properly
  //---------------------------------------
  `SVTEST(connectivity)

    `FAIL_IF(my_apb_coverage_agent.coverage.cg.kind_cp.get_coverage() != 0);
    `FAIL_IF(my_apb_coverage_agent.coverage.cg.addr_max_cp.get_coverage() != 0);
    `FAIL_IF(my_apb_coverage_agent.coverage.cg.data_min_cp.get_coverage() != 0);

    bfm_mstr.write('hfc, 0);

    // NOTE: for some reason, the coverage stats for kind_cp with vcs aren't
    //       returned properly. that's why I have this commented out.
    //`FAIL_IF(my_apb_coverage_agent.coverage.cg.kind_cp.get_coverage() != 50);
    `FAIL_IF(my_apb_coverage_agent.coverage.cg.addr_max_cp.get_coverage() != 100);
    `FAIL_IF(my_apb_coverage_agent.coverage.cg.data_min_cp.get_coverage() != 100);

  `SVTEST_END



  `SVUNIT_TESTS_END

endmodule
