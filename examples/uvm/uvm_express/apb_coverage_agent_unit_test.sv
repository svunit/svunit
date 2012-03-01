//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################

import svunit_pkg::*;
import svunit_uvm_mock_pkg::*;

`include "svunit_defines.svh"
`include "apb_coverage_agent.sv"
`include "apb_if.sv"
typedef class c_apb_coverage_agent_unit_test;

module apb_coverage_agent_unit_test;
  c_apb_coverage_agent_unit_test unittest;
  string name = "apb_coverage_agent_ut";

  initial begin
    //---------------------------
    // start the svunit_uvm_test
    //---------------------------
    svunit_uvm_test_inst("svunit_uvm_test");
  end

  logic clk;
  initial begin
    clk = 1;
    forever #`CLK_PERIOD clk = ~clk;
  end

  apb_if bfm(.clk(clk));

  function void setup();
    unittest = new(name,
                   bfm);
  endfunction
endmodule

class c_apb_coverage_agent_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  apb_coverage_agent my_apb_coverage_agent;
  virtual apb_if bfm;
  virtual apb_if.mstr bfm_mstr;


  //===================================
  // Constructor
  //===================================
  function new(string name,
               virtual apb_if bfm);
    super.new(name);

    this.bfm = bfm;
    this.bfm_mstr = bfm;

    my_apb_coverage_agent = new({ name , "::my_apb_coverage_agent" }, null);
    uvm_config_db#(virtual apb_if.passive_slv)::
      set( uvm_root::get(), { name , "::my_apb_coverage_agent" }, "bfm", this.bfm);

    //-----------------------
    // deactivate by default
    //-----------------------
    svunit_deactivate_uvm_component(my_apb_coverage_agent);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    //----------------------
    // activate for testing
    //----------------------
    svunit_activate_uvm_component(my_apb_coverage_agent);
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

    //---------------------------------------
    // deactivate at the end of unit testing
    //---------------------------------------
    svunit_deactivate_uvm_component(my_apb_coverage_agent);
  endtask

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

  `SVTEST_END(members_not_null)

  //---------------------------------------
  // Test: connectivity
  //
  // do a write and make sure the coverage
  // model is sampled properly
  //---------------------------------------
  `SVTEST(connectivity)
    svunit_uvm_test_start();

    #1 bfm_mstr.async_reset();
    bfm_mstr.write('hfc, 0);

    //repeat(2) @(negedge bfm_mstr.clk);

    `FAIL_IF(my_apb_coverage_agent.coverage.cg.kind_cp.get_coverage() != 50);
    `FAIL_IF(my_apb_coverage_agent.coverage.cg.addr_max_cp.get_coverage() != 100);
    `FAIL_IF(my_apb_coverage_agent.coverage.cg.data_min_cp.get_coverage() != 100);

    svunit_uvm_test_finish();
  `SVTEST_END(connectivity)

  `SVUNIT_TESTS_END

endclass


