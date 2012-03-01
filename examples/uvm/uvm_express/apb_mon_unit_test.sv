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
typedef class c_apb_mon_unit_test;

module apb_mon_unit_test;
  c_apb_mon_unit_test unittest;
  string name = "apb_mon_ut";

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

class c_apb_mon_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  apb_mon my_apb_mon;
  virtual apb_if.mstr bfm;

  uvm_tlm_analysis_fifo #(apb_xaction) af;

  //===================================
  // Constructor
  //===================================
  function new(string name,
               virtual apb_if bfm);
    super.new(name);
    this.bfm = bfm;

    my_apb_mon = new({ name , "::my_apb_mon" }, null);
    my_apb_mon.bfm = bfm;

    // connect a fifo to the mon.ap
    af = new({ name , "::af" }, null);
    my_apb_mon.ap.connect(af.analysis_export);

    //-----------------------
    // deactivate by default
    //-----------------------
    //svunit_deactivate_uvm_component(my_apb_mon);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    //----------------------
    // activate for testing
    //----------------------
    //svunit_activate_uvm_component(my_apb_mon);

    //---------------------
    // reset the interface
    //---------------------
    bfm.async_reset();
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
    //svunit_deactivate_uvm_component(my_apb_mon);
  endtask

  `SVUNIT_TESTS_BEGIN

  //-------------------------------------
  // Test: analysis_port_not_null
  //
  // verify the analysis port is created
  //-------------------------------------
  `SVTEST(analysis_port_not_null)
    svunit_uvm_test_start();

    `FAIL_IF(my_apb_mon.ap == null);

    svunit_uvm_test_finish();
  `SVTEST_END(analysis_port_not_null)

  //---------------------------------------
  // Test: bfm_not_null
  //
  // verify the bfm exists in the monitor
  //---------------------------------------
  `SVTEST(bfm_not_null)
    svunit_uvm_test_start();

    `FAIL_IF(my_apb_mon.bfm == null);

    svunit_uvm_test_finish();
  `SVTEST_END(bfm_not_null)

  //---------------------------------------
  // Test: capture_write_xaction
  //
  // verify a write xaction captured by
  // the interface and written to the
  // analysis port
  //---------------------------------------
  `SVTEST(capture_write_xaction)
    uvm_transaction tr;

    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      bfm.write(0,0);
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
            repeat (3) @(negedge bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

    svunit_uvm_test_finish();
  `SVTEST_END(capture_write_xaction)

  //---------------------------------------
  // Test: capture_b2b_write_xaction
  //
  // verify a write xaction captured by
  // the interface and written to the
  // analysis port
  //---------------------------------------
  `SVTEST(capture_b2b_write_xaction)
    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      repeat (2) bfm.write(0,0);
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
              repeat (3) @(negedge bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end

    svunit_uvm_test_finish();
  `SVTEST_END(capture_b2b_write_xaction)

  //---------------------------------------
  // Test: capture_write_xaction_chk
  //
  // verify the contents of a write xaction
  //---------------------------------------
  `SVTEST(capture_write_xaction_chk)
    apb_xaction tr;

    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      bfm.write('hf,'hff);
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
            repeat (3) @(negedge bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

    svunit_uvm_test_finish();
  `SVTEST_END(capture_write_xaction_chk)

  //---------------------------------------
  // Test: capture_b2b_write_xaction_chk
  //
  // verify the contents of b2b write
  // transactions
  //---------------------------------------
  `SVTEST(capture_b2b_write_xaction_chk)
    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // write a xaction to the bus and wait for
    // a xaction out
    fork
      begin
        bfm.write('haa,'hbb);
        bfm.write('h11,'hffff_ffff);
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
              repeat (3) @(negedge bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end
  `SVTEST_END(capture_b2b_write_xaction_chk)

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

    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // read a xaction from the bus and wait for
    // a xaction out
    fork
      bfm.read(0,rdata);
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
            repeat (3) @(negedge bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

    svunit_uvm_test_finish();
  `SVTEST_END(capture_read_xaction)

  //---------------------------------------
  // Test: capture_b2b_read_xaction
  //
  // verify a read xaction captured by
  // the interface and written to the
  // analysis port
  //---------------------------------------
  `SVTEST(capture_b2b_read_xaction)
    logic [31:0] rdata;

    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // read a xaction to the bus and wait for
    // a xaction out
    fork
      repeat (2) bfm.read(0,rdata);
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
              repeat (3) @(negedge bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end

    svunit_uvm_test_finish();
  `SVTEST_END(capture_b2b_read_xaction)

  //---------------------------------------
  // Test: capture_read_xaction_chk
  //
  // verify the contents of a read xaction
  //---------------------------------------
  `SVTEST(capture_read_xaction_chk)
    apb_xaction tr;
    logic [31:0] rdata;

    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // read a xaction to the bus and wait for
    // a xaction out
    fork
      bfm.prdata = 'hff;
      bfm.read('hf,rdata);
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
            repeat (3) @(negedge bfm.clk);
            `FAIL_IF(1);
          end
        join_any
        disable fork;
      end
    join

    svunit_uvm_test_finish();
  `SVTEST_END(capture_read_xaction_chk)

  //---------------------------------------
  // Test: capture_b2b_read_xaction_chk
  //
  // verify the contents of b2b read
  // transactions
  //---------------------------------------
  `SVTEST(capture_b2b_read_xaction_chk)
    logic [31:0] rdata;

    svunit_uvm_test_start();

    // wait for the bfm to go IDLE
    @(negedge bfm.clk);

    // read a xaction to the bus and wait for
    // a xaction out
    fork
      begin
        bfm.prdata = 'hbb;
        bfm.read('haa,rdata);
        bfm.prdata = 'hffff_ffff;
        bfm.read('h11,rdata);
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
              repeat (3) @(negedge bfm.clk);
              `FAIL_IF(1);
            end
          join_any
          disable fork;
        end
      join
    end
  `SVTEST_END(capture_b2b_read_xaction_chk)

  `SVUNIT_TESTS_END

endclass


