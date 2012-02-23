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

`include "svunit_defines.svh"
`include "svunit_uvm_test.sv"
`include "apb_coverage.sv"
typedef class c_apb_coverage_unit_test;

module apb_coverage_unit_test;
  c_apb_coverage_unit_test unittest;
  string name = "apb_coverage_ut";

  initial begin
    //---------------------------
    // start the svunit_uvm_test
    //---------------------------
    //svunit_uvm_test_inst("svunit_uvm_test");
  end

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

    //-----------------------
    // deactivate by default
    //-----------------------
    svunit_deactivate_uvm_component(my_apb_coverage);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    //----------------------
    // activate for testing
    //----------------------
    svunit_activate_uvm_component(my_apb_coverage);
    svunit_uvm_test_inst("svunit_uvm_test");
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

    //---------------------------------------
    // deactivate at the end of unit testing
    //---------------------------------------
    svunit_deactivate_uvm_component(my_apb_coverage);
  endtask

endclass


