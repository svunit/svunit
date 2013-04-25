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

`define MST_EXPECT(ADDR,WRITE,SEL,ENABLE,DATA) \
  `FAIL_IF(my_apb_slv_if.paddr   !== ADDR); \
  `FAIL_IF(my_apb_slv_if.pwrite  !== WRITE); \
  `FAIL_IF(my_apb_slv_if.psel    !== SEL); \
  `FAIL_IF(my_apb_slv_if.penable !== ENABLE); \
  `FAIL_IF(my_apb_slv_if.pwdata  !== DATA)

`define SLV_EXPECT(WRITE,ADDR,DATA) \
  `FAIL_IF(slv_pwrite  !== WRITE); \
  `FAIL_IF(slv_paddr   !== ADDR); \
  `FAIL_IF(slv_pdata  !== DATA)

`define APB_SET(ADDR,WRITE,SEL,ENABLE,DATA) \
  my_apb_mstr_if.paddr   = ADDR; \
  my_apb_mstr_if.pwrite  = WRITE; \
  my_apb_mstr_if.psel    = SEL; \
  my_apb_mstr_if.penable = ENABLE; \
  my_apb_mstr_if.pwdata  = DATA

`include "svunit_defines.svh"
`include "apb_if.sv"


module apb_if_unit_test;

  string name = "apb_if_ut";
  svunit_testcase svunit_ut;

  logic clk;
  initial begin
    clk = 1;
    forever #`CLK_PERIOD clk = ~clk;
  end

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  apb_if my_apb_slv_if(.clk(clk));
  virtual apb_if.mstr        my_apb_mstr_if;
  virtual apb_if.passive_slv my_apb_pslv_if;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_apb_mstr_if = my_apb_slv_if;
    my_apb_pslv_if = my_apb_slv_if;
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
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

  logic [31:0] rdata;
  logic slv_pwrite;
  logic [7:0] slv_paddr;
  logic [31:0] slv_pdata;

  `SVUNIT_TESTS_BEGIN

  //--------------------------------------------------
  // Test: async_reset_if
  //
  // verify the pins on the interface can be
  // asynchronously reset
  //--------------------------------------------------
  `SVTEST(async_reset_if_test)
    #1 my_apb_mstr_if.async_reset();
    `MST_EXPECT(0, 0, 0, 0, 0);
  `SVTEST_END(async_reset_if_test)

  //--------------------------------------------------
  // Test: sync_reset_if
  //
  // verify the pins on the interface can be
  // synchronously reset (to the negedge of clk)
  //--------------------------------------------------
  `SVTEST(sync_reset_if_test)
    `APB_SET(1, 1, 1, 1, 1);

    @(posedge my_apb_mstr_if.clk);
    fork
      my_apb_mstr_if.sync_reset();
    join_none

    #(`CLK_PERIOD - 1);
    `MST_EXPECT(1, 1, 1, 1, 1);

    @(negedge my_apb_mstr_if.clk) #1;
    `MST_EXPECT(0, 0, 0, 0, 0);
  `SVTEST_END(sync_reset_if_test)

  //--------------------------------------------------
  // Test: write_1_psel
  //
  // verify the psel is asserted for 2 cycles then
  // de-asserted
  //--------------------------------------------------
  `SVTEST(write_1_psel)
    fork
      my_apb_mstr_if.write(0,0);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 0);
  `SVTEST_END(write_1_psel)

  //--------------------------------------------------
  // Test: write_2_psel
  //
  // verify the psel is asserted for 4 cycles then
  // de-asserted (back-to-back writes)
  //--------------------------------------------------
  `SVTEST(write_2_psel)
    fork
      repeat (2) my_apb_mstr_if.write(0,0);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 0);
  `SVTEST_END(write_2_psel)

  //--------------------------------------------------
  // Test: write_1_penable
  //
  // verify the penable is asserted for 1 cycle then
  // de-asserted
  //--------------------------------------------------
  `SVTEST(write_1_penable)
    fork
      my_apb_mstr_if.write(0,0);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
  `SVTEST_END(write_1_penable)

  //--------------------------------------------------
  // Test: write_2_penable
  //
  // verify the penable is asserted twice in 4 cycles
  //--------------------------------------------------
  `SVTEST(write_2_penable)
    fork
      repeat (2) my_apb_mstr_if.write(0,0);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
  `SVTEST_END(write_2_penable)

  //--------------------------------------------------
  // Test: write_1_paddr
  //
  // verify the paddr changes on the first clk edge
  //--------------------------------------------------
  `SVTEST(write_1_paddr)
    fork
      my_apb_mstr_if.write(1,0);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 8'hx);
  `SVTEST_END(write_1_paddr)

  //--------------------------------------------------
  // Test: write_2_paddr
  //
  // verify the paddr transitions directly from 2 to
  // 3 for consecutive writes
  //--------------------------------------------------
  `SVTEST(write_2_paddr)
    fork
      begin
        my_apb_mstr_if.write(2,0);
        my_apb_mstr_if.write(3,0);
      end
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 2);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 2);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 3);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 3);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 8'hx);
  `SVTEST_END(write_2_paddr)

  //--------------------------------------------------
  // Test: write_1_pwdata
  //
  // verify the pwdata changes on the first clk edge
  //--------------------------------------------------
  `SVTEST(write_1_pwdata)
    fork
      my_apb_mstr_if.write(0, 12);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 12);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 12);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 32'hx);
  `SVTEST_END(write_1_pwdata)

  //--------------------------------------------------
  // Test: write_2_pwdata
  //
  // verify the pwdata transitions directly from 13 to
  // 14 for consecutive writes
  //--------------------------------------------------
  `SVTEST(write_2_pwdata)
    fork
      begin
        my_apb_mstr_if.write(0, 13);
        my_apb_mstr_if.write(0, 14);
      end
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 13);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 13);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 14);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 14);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwdata !== 32'hx);
  `SVTEST_END(write_2_pwdata)

  //--------------------------------------------------
  // Test: write_1_pwrite
  //
  // verify the pwrite changes on the first clk edge
  //--------------------------------------------------
  `SVTEST(write_1_pwrite)
    fork
      my_apb_mstr_if.write(0,0);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1'hx);
  `SVTEST_END(write_1_pwrite)

  //--------------------------------------------------
  // Test: write_2_pwrite
  //
  // verify the pwrite stays asserted for consecutive
  // writes
  //--------------------------------------------------
  `SVTEST(write_2_pwrite)
    fork
      repeat (2) my_apb_mstr_if.write(0,0);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1'hx);
  `SVTEST_END(write_2_pwrite)

  //--------------------------------------------------
  // Test: read_1_psel
  //
  // verify the psel is asserted for 2 cycles then
  // de-asserted
  //--------------------------------------------------
  `SVTEST(read_1_psel)
    fork
      my_apb_mstr_if.read(0, rdata);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 0);
  `SVTEST_END(read_1_psel)

  //--------------------------------------------------
  // Test: read_2_psel
  //
  // verify the psel is asserted for 4 cycles then
  // de-asserted (back-to-back reads)
  //--------------------------------------------------
  `SVTEST(read_2_psel)
    fork
      repeat (2) my_apb_mstr_if.read(0, rdata);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.psel !== 0);
  `SVTEST_END(read_2_psel)

  //--------------------------------------------------
  // Test: read_1_penable
  //
  // verify the penable is asserted for 1 cycle then
  // de-asserted
  //--------------------------------------------------
  `SVTEST(read_1_penable)
    fork
      my_apb_mstr_if.read(0, rdata);
    join_none

    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
  `SVTEST_END(read_1_penable)

  //--------------------------------------------------
  // Test: read_2_penable
  //
  // verify the penable is asserted twice in 4 cycles
  //--------------------------------------------------
  `SVTEST(read_2_penable)
    fork
      repeat (2) my_apb_mstr_if.read(0, rdata);
    join_none
 
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 1);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.penable !== 0);
  `SVTEST_END(read_2_penable)
 
  //--------------------------------------------------
  // Test: read_1_paddr
  //
  // verify the paddr changes on the first clk edge
  //--------------------------------------------------
  `SVTEST(read_1_paddr)
    fork
      my_apb_mstr_if.read('hf, rdata);
    join_none
 
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 'hf);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 'hf);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 8'hx);
  `SVTEST_END(read_1_paddr)
 
  //--------------------------------------------------
  // Test: read_2_paddr
  //
  // verify the paddr transitions directly from fe to
  // ff for consecutive reads
  //--------------------------------------------------
  `SVTEST(read_2_paddr)
    fork
      begin
        my_apb_mstr_if.read('hfe, rdata);
        my_apb_mstr_if.read('hff, rdata);
      end
    join_none
 
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 'hfe);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 'hfe);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 'hff);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 'hff);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.paddr !== 8'hx);
  `SVTEST_END(read_2_paddr)
 
  //--------------------------------------------------
  // Test: read_1_prdata
  //
  // verify the prdata is captured in the enable state
  //--------------------------------------------------
  `SVTEST(read_1_prdata)
    fork
      begin
        my_apb_mstr_if.read(0, rdata);
        `FAIL_IF(rdata !== 'hffff);
      end
    join_none
 
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hffff;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
  `SVTEST_END(read_1_prdata)
 
  //--------------------------------------------------
  // Test: read_2_prdata
  //
  // verify the prdata is captured correctly for back
  // to back reads
  //--------------------------------------------------
  `SVTEST(read_2_prdata)
    fork
      begin
        my_apb_mstr_if.read(0, rdata);
        `FAIL_IF(rdata !== 'heeee);

        my_apb_mstr_if.read(0, rdata);
        `FAIL_IF(rdata !== 'hcccc);
      end
    join_none

    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'heeee;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hcccc;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
  `SVTEST_END(read_2_prdata)
 
  //--------------------------------------------------
  // Test: read_1_pwrite
  //
  // verify the pwrite changes on the first clk edge
  //--------------------------------------------------
  `SVTEST(read_1_pwrite)
    fork
      my_apb_mstr_if.read(0, rdata);
    join_none
 
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1'hx);
  `SVTEST_END(read_1_pwrite)
 
  //--------------------------------------------------
  // Test: read_2_pwrite
  //
  // verify the pwrite stays deasserted for consecutive
  // reads
  //--------------------------------------------------
  `SVTEST(read_2_pwrite)
    fork
      repeat (2) my_apb_mstr_if.read(0, rdata);
    join_none
 
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 0);
    @(negedge my_apb_slv_if.clk) #1 `FAIL_IF(my_apb_slv_if.pwrite !== 1'hx);
  `SVTEST_END(read_2_pwrite)

  //--------------------------------------------------
  // Test: slv_1_capture_write
  //
  // capture the pwrite, paddr and pdata for a write
  // using the passive slv interface
  //--------------------------------------------------
  `SVTEST(slv_capture_1_write)
    fork
      my_apb_mstr_if.write(2, 3);
      my_apb_pslv_if.capture(slv_pwrite, slv_paddr, slv_pdata);
    join
    `SLV_EXPECT(1, 2, 3);
  `SVTEST_END(slv_capture_1_write)

  //--------------------------------------------------
  // Test: slv_2_capture_write
  //
  // capture the pwrite, paddr and pdata for a write
  // using the passive slv interface
  //--------------------------------------------------
  `SVTEST(slv_capture_2_write)
    fork
      begin
        my_apb_mstr_if.write(4, 5);
        my_apb_mstr_if.write('hf3, 'hffff);
      end
      begin
        my_apb_pslv_if.capture(slv_pwrite, slv_paddr, slv_pdata);
        `SLV_EXPECT(1, 4, 5);

        my_apb_pslv_if.capture(slv_pwrite, slv_paddr, slv_pdata);
        `SLV_EXPECT(1, 'hf3, 'hffff);
      end
    join
  `SVTEST_END(slv_capture_2_write)

  //--------------------------------------------------
  // Test: slv_capture_1_read
  //
  // capture the pwrite, paddr and pdata for a read
  // using the passive slv interface
  //--------------------------------------------------
  `SVTEST(slv_capture_1_read)
    fork
      begin
        my_apb_mstr_if.read('h55, rdata);

        `FAIL_IF(rdata !== 'h1111);
      end
      begin
        my_apb_pslv_if.capture(slv_pwrite, slv_paddr, slv_pdata);
        `SLV_EXPECT(0, 'h55, 'h1111);
      end
    join_none

    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'h1111;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
  `SVTEST_END(slv_capture_1_read)

  //--------------------------------------------------
  // Test: slv_capture_2_read
  //
  // capture the pwrite, paddr and pdata for 2 reads
  // using the passive slv interface
  //--------------------------------------------------
  `SVTEST(slv_capture_2_read)
    fork
      begin
        my_apb_mstr_if.read('h22, rdata);
        `FAIL_IF(rdata !== 'h9999);

        my_apb_mstr_if.read('h10, rdata);
        `FAIL_IF(rdata !== 'h7777_7777);
      end
      begin
        my_apb_pslv_if.capture(slv_pwrite, slv_paddr, slv_pdata);
        `SLV_EXPECT(0, 'h22, 'h9999);

        my_apb_pslv_if.capture(slv_pwrite, slv_paddr, slv_pdata);
        `SLV_EXPECT(0, 'h10, 'h7777_7777);
      end
    join_none

    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'h9999;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'h7777_7777;
    @(negedge my_apb_slv_if.clk) #1 my_apb_slv_if.prdata = 'hx;
  `SVTEST_END(slv_capture_2_read)


  `SVUNIT_TESTS_END

endmodule
