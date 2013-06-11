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
`include "apb_mon.sv"
`include "apb_xaction.sv"
`include "apb_if.sv"


module apb_mon_unit_test;

  string name = "apb_mon_ut";
  svunit_testcase svunit_ut;

  logic clk;
  initial begin
    clk = 1;
    forever #`CLK_PERIOD clk = ~clk;
  end

  apb_if slv_bfm(.clk(clk));
  virtual apb_if.mstr mstr_bfm;
  virtual apb_if.passive_slv pslv_bfm;

  uvm_tlm_analysis_fifo #(apb_xaction) af;

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  apb_mon my_apb_mon;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_apb_mon = new({ name , "::my_apb_mon" }, null);
    mstr_bfm = slv_bfm;
    my_apb_mon.bfm = slv_bfm;

    // connect a fifo to the mon.ap
    af = new({ name , "::af" }, null);
    my_apb_mon.ap.connect(af.analysis_export);

    //-----------------------
    // deactivate by default
    //-----------------------
    svunit_deactivate_uvm_component(my_apb_mon);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();

    //----------------------
    // activate for testing
    //----------------------
    svunit_activate_uvm_component(my_apb_mon);

    //---------------------
    // reset the interface
    //---------------------
    mstr_bfm.async_reset();

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
    svunit_deactivate_uvm_component(my_apb_mon);
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
  // Test: analysis_port_not_null
  //
  // verify the analysis port is created
  //-------------------------------------
  `SVTEST(analysis_port_not_null)

    `FAIL_IF(my_apb_mon.ap == null);

  `SVTEST_END

  //---------------------------------------
  // Test: bfm_not_null
  //
  // verify the bfm exists in the monitor
  //---------------------------------------
  `SVTEST(bfm_not_null)

    `FAIL_IF(my_apb_mon.bfm == null);

  `SVTEST_END

  //---------------------------------------
  // Test: capture_write_xaction
  //
  // verify a write xaction captured by
  // the interface and written to the
  // analysis port
  //---------------------------------------
  `SVTEST(capture_write_xaction)
    uvm_transaction tr;

    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      mstr_bfm.write(0,0);
    join_none

    fork
      begin
        fork
          // verify the tr is written to the ap
          begin
            uvm_transaction tr;
            af.get(tr);
            `FAIL_IF(tr == null);
          end

          // watchdog
          begin
            repeat (3) @(negedge mstr_bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

  `SVTEST_END

  //---------------------------------------
  // Test: capture_b2b_write_xaction
  //
  // verify a write xaction captured by
  // the interface and written to the
  // analysis port
  //---------------------------------------
  `SVTEST(capture_b2b_write_xaction)
    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      repeat (2) mstr_bfm.write(0,0);
    join_none

    repeat (2) begin
      fork
        begin
          fork
            // verify the tr is written to the ap
            begin
              uvm_transaction tr;
              af.get(tr);
              `FAIL_IF(tr == null);
            end

            // watchdog
            begin
              repeat (3) @(negedge mstr_bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end

  `SVTEST_END

  //---------------------------------------
  // Test: capture_write_xaction_chk
  //
  // verify the contents of a write xaction
  //---------------------------------------
  `SVTEST(capture_write_xaction_chk)
    apb_xaction tr;

    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      mstr_bfm.write('hf,'hff);
    join_none

    fork
      begin
        fork
          // verify the tr is written to the ap
          begin
            apb_xaction tr;
            af.get(tr);
            `FAIL_IF(tr.kind !== apb_xaction::WRITE);
            `FAIL_IF(tr.addr !== 'hf);
            `FAIL_IF(tr.data !== 'hff);
          end

          // watchdog
          begin
            repeat (3) @(negedge mstr_bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

  `SVTEST_END

  //---------------------------------------
  // Test: capture_b2b_write_xaction_chk
  //
  // verify the contents of b2b write
  // transactions
  //---------------------------------------
  `SVTEST(capture_b2b_write_xaction_chk)
    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      begin
        mstr_bfm.write('haa,'hbb);
        mstr_bfm.write('h11,'hffff_ffff);
      end
    join_none

    for (int i=0; i<2; i+=1) begin
      fork
        begin
          fork
            // verify the tr is written to the ap
            begin
              apb_xaction tr;
              af.get(tr);
              if (i == 0) begin
                `FAIL_IF(tr.kind !== apb_xaction::WRITE);
                `FAIL_IF(tr.addr !== 'haa);
                `FAIL_IF(tr.data !== 'hbb);
              end
              else begin
                `FAIL_IF(tr.kind !== apb_xaction::WRITE);
                `FAIL_IF(tr.addr !== 'h11);
                `FAIL_IF(tr.data !== 'hffff_ffff);
              end
            end

            // watchdog
            begin
              repeat (3) @(negedge mstr_bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end
  `SVTEST_END

  //---------------------------------------
  // Test: capture_read_xaction
  //
  // verify a read xaction captured by
  // the interface and written to the
  // analysis port
  //---------------------------------------
  `SVTEST(capture_read_xaction)
    uvm_transaction tr;
    logic [31:0] rdata;

    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // read a xaction from the bus and wait for
    // a xaction out
    fork
      mstr_bfm.read(0,rdata);
    join_none

    fork
      begin
        fork
          // verify the tr is written to the ap
          begin
            uvm_transaction tr;
            af.get(tr);
            `FAIL_IF(tr == null);
          end

          // watchdog
          begin
            repeat (3) @(negedge mstr_bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

  `SVTEST_END

  //---------------------------------------
  // Test: capture_b2b_read_xaction
  //
  // verify a read xaction captured by
  // the interface and written to the
  // analysis port
  //---------------------------------------
  `SVTEST(capture_b2b_read_xaction)
    logic [31:0] rdata;

    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // read a xaction to the bus and wait for
    // a xaction out
    fork
      repeat (2) mstr_bfm.read(0,rdata);
    join_none

    repeat (2) begin
      fork
        begin
          fork
            // verify the tr is written to the ap
            begin
              uvm_transaction tr;
              af.get(tr);
              `FAIL_IF(tr == null);
            end

            // watchdog
            begin
              repeat (3) @(negedge mstr_bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end

  `SVTEST_END

  //---------------------------------------
  // Test: capture_read_xaction_chk
  //
  // verify the contents of a read xaction
  //---------------------------------------
  `SVTEST(capture_read_xaction_chk)
    apb_xaction tr;
    logic [31:0] rdata;

    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // read a xaction to the bus and wait for
    // a xaction out
    fork
      slv_bfm.prdata = 'hff;
      mstr_bfm.read('hf,rdata);
    join_none

    fork
      begin
        fork
          // verify the tr is written to the ap
          begin
            apb_xaction tr;
            af.get(tr);
            `FAIL_IF(tr.kind !== apb_xaction::READ);
            `FAIL_IF(tr.addr !== 'hf);
            `FAIL_IF(tr.data !== 'hff);
          end

          // watchdog
          begin
            repeat (3) @(negedge mstr_bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

  `SVTEST_END

  //---------------------------------------
  // Test: capture_b2b_read_xaction_chk
  //
  // verify the contents of b2b read
  // transactions
  //---------------------------------------
  `SVTEST(capture_b2b_read_xaction_chk)
    logic [31:0] rdata;

    // wait for the bfm to go IDLE
    @(negedge mstr_bfm.clk);

    // read a xaction to the bus and wait for
    // a xaction out
    fork
      begin
        slv_bfm.prdata = 'hbb;
        mstr_bfm.read('haa,rdata);
        slv_bfm.prdata = 'hffff_ffff;
        mstr_bfm.read('h11,rdata);
      end
    join_none

    for (int i=0; i<2; i+=1) begin
      fork
        begin
          fork
            // verify the tr is written to the ap
            begin
              apb_xaction tr;
              af.get(tr);
              if (i == 0) begin
                `FAIL_IF(tr.kind !== apb_xaction::READ);
                `FAIL_IF(tr.addr !== 'haa);
                `FAIL_IF(tr.data !== 'hbb);
              end
              else begin
                `FAIL_IF(tr.kind !== apb_xaction::READ);
                `FAIL_IF(tr.addr !== 'h11);
                `FAIL_IF(tr.data !== 'hffff_ffff);
              end
            end

            // watchdog
            begin
              repeat (3) @(negedge mstr_bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
