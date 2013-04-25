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

module apb_coverage_unit_test;

  string name = "apb_coverage_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  apb_coverage my_apb_coverage;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

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
    svunit_ut.setup();

    //----------------------
    // activate for testing
    //----------------------
    svunit_activate_uvm_component(my_apb_coverage);

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
    svunit_deactivate_uvm_component(my_apb_coverage);
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

  //-------------------------------------
  // Test: write_method
  //
  // verify the write_method sets the
  // local obj to be sampled and that
  // the addr_min_cp and data_min_cp are
  // sampled correctly
  //-------------------------------------
  `SVTEST(write_method)
    apb_xaction a, b;

    `FAIL_IF(my_apb_coverage.cg.addr_min_cp.get_coverage() != 0);
    `FAIL_IF(my_apb_coverage.cg.data_min_cp.get_coverage() != 0);
    `FAIL_IF(my_apb_coverage.cg.kind_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { addr == 0;
                               data == 0;
                               kind == WRITE;
                             });

    my_apb_coverage.write(a);

    $cast(b, my_apb_coverage.get_sampled_obj());
    `FAIL_IF(!a.compare(b));
    `FAIL_IF(my_apb_coverage.cg.addr_min_cp.get_coverage() != 100);
    `FAIL_IF(my_apb_coverage.cg.data_min_cp.get_coverage() != 100);
    `FAIL_IF(my_apb_coverage.cg.kind_cp.get_coverage() != 50);

    my_apb_coverage.cg.start();
  `SVTEST_END(write_method)

  //-------------------------------------
  // Test: addr_max_cp
  //
  // verify the bin for addr == fc
  //-------------------------------------
  `SVTEST(addr_max_cp)
    apb_xaction a;

    `FAIL_IF(my_apb_coverage.cg.addr_max_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { addr == 'hfc;
                               data == 0; 
                               kind == WRITE;
                             });

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
    void'(a.randomize() with { addr == 1;
                               data == 0; 
                               kind == WRITE;
                             });

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
  // Test: data_max_cp
  //
  // verify the bin for data == ffff_ffff
  //-------------------------------------
  `SVTEST(data_max_cp)
    apb_xaction a;

    `FAIL_IF(my_apb_coverage.cg.data_max_cp.get_coverage() != 0);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { data == 'hffff_ffff;
                               kind == WRITE;
                             });

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
    void'(a.randomize() with { data == 1;
                               kind == WRITE;
                             });

    my_apb_coverage.write(a);

    `FAIL_IF($rtoi(my_apb_coverage.cg.data_bins_cp.get_coverage()) != (100/32));

    for (int i=1; i<32; i+=1) begin
      a.data += 'hffff_fffe/32;

      my_apb_coverage.write(a);

      `FAIL_IF($rtoi(my_apb_coverage.cg.data_bins_cp.get_coverage()) != ((i+1) * 100/32));
    end

    `FAIL_IF(my_apb_coverage.cg.data_bins_cp.get_coverage() != 100);

  `SVTEST_END(data_bins_cp)

  //-------------------------------------
  // Test: kind_cp
  //
  // verify the kind for read and write
  //-------------------------------------
  `SVTEST(kind_cp)
    apb_xaction a;

    my_apb_coverage.cg.kind_cp.start();

    `FAIL_IF(my_apb_coverage.cg.kind_cp.get_coverage() != 50);

    a = apb_xaction::type_id::create();
    void'(a.randomize() with { kind == READ; } );

    my_apb_coverage.write(a);

    `FAIL_IF(my_apb_coverage.cg.kind_cp.get_coverage() != 100);
 
  `SVTEST_END(kind_cp)


  `SVUNIT_TESTS_END

endmodule
