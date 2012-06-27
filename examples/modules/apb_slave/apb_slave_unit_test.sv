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
`include "apb_slave.sv"
typedef class c_apb_slave_unit_test;


// virtual interface to the uut
interface apb_slave_unit_test_if
#(
  addrWidth = 8,
  dataWidth = 32
)
(
  input                 clk
);
  logic                 rst_n;
  logic [addrWidth-1:0] paddr;
  logic                 pwrite;
  logic                 psel;
  logic                 penable;
  logic [dataWidth-1:0] pwdata;
  logic [dataWidth-1:0] prdata;
endinterface

module apb_slave_unit_test;
  c_apb_slave_unit_test unittest;
  string name = "apb_slave_ut";

  // clk generator
  reg clk;
  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end

  // uut instance and connections to the virtual interface
  apb_slave my_apb_slave(.clk(clk),
                         .rst_n(my_apb_slave_if.rst_n),
                         .paddr(my_apb_slave_if.paddr),
                         .pwrite(my_apb_slave_if.pwrite),
                         .psel(my_apb_slave_if.psel),
                         .penable(my_apb_slave_if.penable),
                         .pwdata(my_apb_slave_if.pwdata),
                         .prdata(my_apb_slave_if.prdata));

  // virtual interface instance
  apb_slave_unit_test_if my_apb_slave_if(.clk(clk));

  function void setup();
    unittest = new(name, my_apb_slave_if);
  endfunction
endmodule

class c_apb_slave_unit_test extends svunit_testcase;

  virtual apb_slave_unit_test_if my_apb_slave_if;
  logic [7:0] addr;
  logic [31:0] data, rdata;

  //===================================
  // Constructor
  //===================================
  function new(string name,
               virtual apb_slave_unit_test_if my_apb_slave_if);
    super.new(name);

    this.my_apb_slave_if = my_apb_slave_if;
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    super.setup();

    //-----------------------------------------
    // move the bus into the IDLE state
    // before each test
    //-----------------------------------------
    idle();

    //-----------------------------
    // then do a reset for the uut
    //-----------------------------
    my_apb_slave_if.rst_n = 0;
    repeat (8) @(posedge my_apb_slave_if.clk);
    my_apb_slave_if.rst_n = 1;
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    super.teardown();

    // nothing special worth doing here
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


  //************************************************************
  // Test:
  //   single_write_then_read
  //
  // Desc:
  //   do a write then a read at the same address
  //************************************************************
  `SVTEST(single_write_then_read)
    addr = 'h32;
    data = 'h61;

    write(addr, data);
    read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SVTEST_END(single_write_then_read)


  //************************************************************
  // Test:
  //   write_wo_psel
  //
  // Desc:
  //   do a write then a read at the same address but insert a
  //   write without psel asserted during setup to ensure mem
  //   isn't corrupted by a protocol error.
  //************************************************************
  `SVTEST(write_wo_psel)
    addr = 'h0;
    data = 'hffff_ffff;

    write(addr, data);
    write(addr, 'hff, 0, 0);
    read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SVTEST_END(write_wo_psel)


  //************************************************************
  // Test:
  //   write_wo_write
  //
  // Desc:
  //   do a write then a read at the same address but insert a
  //   write without pwrite asserted during setup to ensure mem
  //   isn't corrupted by a protocol error.
  //************************************************************
  `SVTEST(write_wo_write)
    addr = 'h10;
    data = 'h99;

    write(addr, data);
    write(addr, 'hff, 0, 1, 0);
    read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SVTEST_END(write_wo_write)


  //************************************************************
  // Test:
  //   _2_writes_then_2_reads
  //
  // Desc:
  //   Do back-to-back writes then back-to-back reads
  //************************************************************
  `SVTEST(_2_writes_then_2_reads)
    addr = 'hfe;
    data = 'h31;

    write(addr, data, 1);
    write(addr+1, data+1, 1);
    read(addr, rdata, 1);
    `FAIL_IF(data !== rdata);
    read(addr+1, rdata, 1);
    `FAIL_IF(data+1 !== rdata);

  `SVTEST_END(_2_writes_then_2_reads)


  `SVUNIT_TESTS_END


  //-------------------------------------------------------------------------------
  //
  // write ()
  //
  // Simple write method used in the unit tests. Includes options for back-to-back
  // writes and protocol errors on the psel and pwrite.
  //
  //-------------------------------------------------------------------------------
  task write(logic [7:0] addr,
             logic [31:0] data,
             logic back2back = 0,
             logic setup_psel = 1,
             logic setup_pwrite = 1);

    // if !back2back, insert an idle cycle before the write
    if (!back2back) begin
      @(negedge my_apb_slave_if.clk);
      my_apb_slave_if.psel = 0;
      my_apb_slave_if.penable = 0;
    end

    // this is the SETUP state where the psel, pwrite, paddr and pdata are set
    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = setup_psel;     // use setup_psel == 0 to test a protocol error on the psel
    my_apb_slave_if.pwrite = setup_pwrite;  // use setup_pwrite == 0 to test a protocol error on the pwrite
    my_apb_slave_if.paddr = addr;
    my_apb_slave_if.pwdata = data;
    my_apb_slave_if.penable = 0;

    // this is the ENABLE state where the penable is asserted
    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.pwrite = 1;
    my_apb_slave_if.penable = 1;
    my_apb_slave_if.psel = 1;
  endtask


  //-------------------------------------------------------------------------------
  //
  // read ()
  //
  // Simple read method used in the unit tests. Includes options for back-to-back
  // reads.
  //
  //-------------------------------------------------------------------------------
  task read(logic [7:0] addr, output logic [31:0] data, input logic back2back = 0);

    // if !back2back, insert an idle cycle before the read
    if (!back2back) begin
      @(negedge my_apb_slave_if.clk);
      my_apb_slave_if.psel = 0;
      my_apb_slave_if.penable = 0;
    end

    // this is the SETUP state where the psel, pwrite and paddr
    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = 1;
    my_apb_slave_if.paddr = addr;
    my_apb_slave_if.penable = 0;
    my_apb_slave_if.pwrite = 0;

    // this is the ENABLE state where the penable is asserted
    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.penable = 1;

    // the prdata should be flopped after the subsequent posedge
    @(posedge my_apb_slave_if.clk);
    #1 data = my_apb_slave_if.prdata;
  endtask


  //-------------------------------------------------------------------------------
  //
  // idle ()
  //
  // Clear the all the inputs to the uut (i.e. move to the IDLE state)
  //
  //-------------------------------------------------------------------------------
  task idle();
    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = 0;
    my_apb_slave_if.penable = 0;
    my_apb_slave_if.pwrite = 0;
    my_apb_slave_if.paddr = 0;
    my_apb_slave_if.pwdata = 0;
  endtask

endclass
