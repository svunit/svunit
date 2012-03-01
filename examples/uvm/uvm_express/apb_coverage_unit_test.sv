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
`include "apb_coverage.sv"
typedef class c_apb_coverage_unit_test;

module apb_coverage_unit_test;
  c_apb_coverage_unit_test unittest;
  string name = "apb_coverage_ut";

  initial begin
    //---------------------------
    // start the svunit_uvm_test
    //---------------------------
    svunit_uvm_test_inst("svunit_uvm_test");
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

  `SVUNIT_TESTS_BEGIN 

  //-------------------------------------
  // Test: write_method
  //
  // verify the write_method sets the
  // local obj to be sampled
  //-------------------------------------
  `SVTEST(write_method)
    apb_xaction a, b;

    svunit_uvm_test_start();

    a = apb_xaction::type_id::create();
    void'(a.randomize());

    my_apb_coverage.cg.stop();

    my_apb_coverage.write(a);
    $cast(b, my_apb_coverage.get_sampled_obj());

    `FAIL_IF(!a.compare(b));

    my_apb_coverage.cg.start();
  `SVTEST_END(write_method)

  //-------------------------------------
  // Test: addr_min_cp
  //
  // verify the bin for addr == 0
  //-------------------------------------
  `SVTEST(addr_min_cp)
    apb_xaction a;

    // disable the groups we're not concerned with to
    // avoid bogus results
    my_apb_coverage.cg.data_min_cp.stop();
    my_apb_coverage.cg.data_max_cp.stop();
    my_apb_coverage.cg.data_bins_cp.stop();
    my_apb_coverage.cg.kind_cp.stop();

    `FAIL_IF(my_apb_coverage.cg.addr_min_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { addr == 0; } );

    my_apb_coverage.write(a);

    `FAIL_IF(my_apb_coverage.cg.addr_min_cp.get_coverage() != 100);
 
  `SVTEST_END(addr_min_cp)

  //-------------------------------------
  // Test: addr_max_cp
  //
  // verify the bin for addr == fc
  //-------------------------------------
  `SVTEST(addr_max_cp)
    apb_xaction a;

    `FAIL_IF(my_apb_coverage.cg.addr_max_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { addr == 'hfc; } );

    my_apb_coverage.write(a);

    `FAIL_IF(my_apb_coverage.cg.addr_max_cp.get_coverage() != 100);
 
  `SVTEST_END(addr_max_cp)

  //-------------------------------------
  // Test: addr_bins_cp
  //
  // verify 16 bins for addr between
  // 1:'hf8
  //-------------------------------------
  `SVTEST(addr_bins_cp)
    apb_xaction a;

    `FAIL_IF(my_apb_coverage.cg.addr_bins_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { addr == 1; } );

    my_apb_coverage.write(a);

    `FAIL_IF($rtoi(my_apb_coverage.cg.addr_bins_cp.get_coverage()) != (100/16));

    for (int i=1; i<16; i+=1) begin
      a.addr += 'hf8/16;

      my_apb_coverage.write(a);

      `FAIL_IF($rtoi(my_apb_coverage.cg.addr_bins_cp.get_coverage()) != ((i+1) * 100/16));
    end

    `FAIL_IF(my_apb_coverage.cg.addr_bins_cp.get_coverage() != 100);
 
  `SVTEST_END(addr_bins_cp)

  //-------------------------------------
  // Test: data_min_cp
  //
  // verify the bin for data == 0
  //-------------------------------------
  `SVTEST(data_min_cp)
    apb_xaction a;

    my_apb_coverage.cg.data_min_cp.start();
    my_apb_coverage.cg.data_max_cp.start();
    my_apb_coverage.cg.data_bins_cp.start();

    `FAIL_IF(my_apb_coverage.cg.data_min_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { data == 0; } );

    my_apb_coverage.write(a);

    `FAIL_IF(my_apb_coverage.cg.data_min_cp.get_coverage() != 100);
 
  `SVTEST_END(data_min_cp)

  //-------------------------------------
  // Test: data_max_cp
  //
  // verify the bin for data == ffff_ffff
  //-------------------------------------
  `SVTEST(data_max_cp)
    apb_xaction a;

    `FAIL_IF(my_apb_coverage.cg.data_max_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { data == 'hffff_ffff; } );

    my_apb_coverage.write(a);

    `FAIL_IF(my_apb_coverage.cg.data_max_cp.get_coverage() != 100);
 
  `SVTEST_END(data_max_cp)

  //-------------------------------------
  // Test: data_bins_cp
  //
  // verify 32 bins for data between
  // 1:'hffff_fffe
  //-------------------------------------
  `SVTEST(data_bins_cp)
    apb_xaction a;

    `FAIL_IF(my_apb_coverage.cg.data_bins_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { data == 1; } );

    my_apb_coverage.write(a);

    `FAIL_IF($rtoi(my_apb_coverage.cg.data_bins_cp.get_coverage()) != (100/32));

    for (int i=1; i<32; i+=1) begin
      a.data += 'hffff_fffe/32;

      my_apb_coverage.write(a);

      `FAIL_IF($rtoi(my_apb_coverage.cg.data_bins_cp.get_coverage()) != ((i+1) * 100/32));
    end

    `FAIL_IF(my_apb_coverage.cg.data_bins_cp.get_coverage() != 100);

    svunit_uvm_test_finish();

  `SVTEST_END(data_bins_cp)

  //-------------------------------------
  // Test: kind_cp
  //
  // verify the kind for read and write
  //-------------------------------------
  `SVTEST(kind_cp)
    apb_xaction a;

    my_apb_coverage.cg.kind_cp.start();

    `FAIL_IF(my_apb_coverage.cg.kind_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { kind == WRITE; } );

    my_apb_coverage.write(a);

    `FAIL_IF(my_apb_coverage.cg.kind_cp.get_coverage() != 50);

    void'(a.randomize() with { kind == READ; } );

    my_apb_coverage.write(a);

    `FAIL_IF(my_apb_coverage.cg.kind_cp.get_coverage() != 100);
 
  `SVTEST_END(kind_cp)

  `SVUNIT_TESTS_END 

endclass


