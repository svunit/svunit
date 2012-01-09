import svunit_pkg::*;

`define CLK_PERIOD #5

`define APB_WEXPECT(ADDR,WRITE,SEL,ENABLE,DATA) \
  `FAIL_IF(my_apb_if.paddr   !== ADDR); \
  `FAIL_IF(my_apb_if.pwrite  !== WRITE); \
  `FAIL_IF(my_apb_if.psel    !== SEL); \
  `FAIL_IF(my_apb_if.penable !== ENABLE); \
  `FAIL_IF(my_apb_if.pwdata  !== DATA); \

`include "apb_mst.sv"
typedef class c_apb_mst_unit_test;

module apb_mst_unit_test;
  c_apb_mst_unit_test unittest;
  string name = "apb_mst_ut";

  logic clk;
  initial begin
    clk = 1;
    forever `CLK_PERIOD clk = ~clk;
  end

  apb_if my_apb_if(
                   .clk(clk)
                  );

  function void setup();
    unittest = new(name);
    unittest.my_apb_if = my_apb_if;
  endfunction
endmodule

class c_apb_mst_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  apb_mst my_apb_mst;
  virtual apb_if my_apb_if;
  vmm_channel #(amba_xaction) inbox;


  //===================================
  // Constructor
  //===================================
  function new(string name);
    super.new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    my_apb_mst = new("my_apb_mst", "", -1,
                     inbox,
                     my_apb_if);
    /* Place Setup Code Here */
  endtask


  //===================================
  // This is where we run all the Unit
  // Tests
  //===================================
  task run_test();
    super.run_test();
    `INFO("Running Unit Tests for class: apb_mst:");
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    super.teardown();
    /* Place Teardown Code Here */
  endtask

  `SVUNIT_TESTS_BEGIN


  //--------------------------------------------------
  // Test: put_get_cmd_inbox_test
  //
  // verify the cmd_inbox exists and it's accessible
  //--------------------------------------------------
  `SVTEST(put_get_cmd_inbox_test)
    `FAIL_IF(my_apb_mst.cmd_inbox == null);
    begin
      amba_xaction put_tr = new();
      vmm_data get_tr;
      string diff;

      fork
        my_apb_mst.cmd_inbox.get(get_tr);
      join_none
      my_apb_mst.cmd_inbox.put(put_tr);

      `FAIL_IF(!put_tr.compare(get_tr, diff));
    end
  `SVTEST_END(put_get_cmd_inbox_test)


  //----------------------------------------------
  // Test: cmd_consumed_test
  //
  // verify commands written to the cmd_inbox are
  // consumed by some process (verify the process
  // is started)
  //----------------------------------------------
  `SVTEST(cmd_consumed_test)
    amba_xaction put_tr = new();

    my_apb_mst.reset_xactor();
    my_apb_mst.start_xactor();
    my_apb_mst.cmd_inbox.put(put_tr);
    #0 `FAIL_IF(my_apb_mst.cmd_inbox.size() != 0);

    my_apb_mst.stop_xactor();
  `SVTEST_END(cmd_consumed_test)


  //----------------------------------------
  // Test: xactor_reset_test
  //
  // verify the bus outputs are inactive on
  // reset
  //----------------------------------------
  `SVTEST(xactor_reset_test)
    my_apb_mst.reset_xactor();

    `APB_WEXPECT(0, 0, 0, 0, 0)
  `SVTEST_END(xactor_reset_test)


  //--------------------------------------------------
  // Test: apb_wsetup_test
  //
  // verify the apb setup state for a write where the
  // paddr, pwrite and psel are driven active
  //--------------------------------------------------
  `SVTEST(apb_wsetup_test)
    amba_xaction put_tr = new();

    my_apb_mst.reset_xactor();
    my_apb_mst.start_xactor();

    put_tr.addr = 1;
    put_tr.write = 1;
    put_tr.data = 1;
    my_apb_mst.cmd_inbox.put(put_tr);

    @(posedge my_apb_if.clk);

    `APB_WEXPECT(1, 1, 1, 0, 1)

    my_apb_mst.stop_xactor();
  `SVTEST_END(apb_wsetup_test)


  //--------------------------------------------------
  // Test: apb_wenable_test
  //
  // verify the apb enable state for a write where the
  // paddr, pwrite and psel remain active and the
  // penable is also driven active
  //--------------------------------------------------
  `SVTEST(apb_wenable_test)
    amba_xaction put_tr = new();

    my_apb_mst.reset_xactor();
    my_apb_mst.start_xactor();

    put_tr.addr = 1;
    put_tr.write = 1;
    put_tr.data = 1;
    my_apb_mst.cmd_inbox.put(put_tr);

    repeat (2) @(posedge my_apb_if.clk);

    `APB_WEXPECT(1, 1, 1, 1, 1)

    my_apb_mst.stop_xactor();
  `SVTEST_END(apb_wenable_test)


  //--------------------------------------------------
  // Test: apb_widle_test
  //
  // verify the apb idle state for a write where the
  // psel and penable are driven inactive
  //--------------------------------------------------
  `SVTEST(apb_widle_test)
    amba_xaction put_tr = new();

    my_apb_mst.reset_xactor();
    my_apb_mst.start_xactor();

    put_tr.addr = 1;
    put_tr.write = 1;
    put_tr.data = 1;
    my_apb_mst.cmd_inbox.put(put_tr);

    repeat (3) @(posedge my_apb_if.clk);

    `APB_WEXPECT(1, 1, 0, 0, 1)

    my_apb_mst.stop_xactor();
  `SVTEST_END(apb_widle_test)


  //-----------------------------------------------
  // Test: apb_wb2b_test
  //
  // verify the transition directly from enable to
  // setup for back-to-back writes then to enable
  // and back to idle
  //-----------------------------------------------
  `SVTEST(apb_wb2b_test)
    amba_xaction put_tr = new();

    my_apb_mst.reset_xactor();
    my_apb_mst.start_xactor();

    put_tr.addr = 1;
    put_tr.write = 1;
    put_tr.data = 1;
    fork
      repeat (2) my_apb_mst.cmd_inbox.put(put_tr);
    join_none

    repeat (3) @(posedge my_apb_if.clk);
    `APB_WEXPECT(1, 1, 1, 0, 1)

    @(posedge my_apb_if.clk);
    `APB_WEXPECT(1, 1, 1, 1, 1)

    @(posedge my_apb_if.clk);
    `APB_WEXPECT(1, 1, 0, 0, 1)

    my_apb_mst.stop_xactor();
  `SVTEST_END(apb_wb2b_test)


  //--------------------------------------------------
  // Test: apb_wdata_addr_max_test
  //
  // verify the apb setup state for a write where the
  // paddr, pwrite and psel are driven active
  //--------------------------------------------------
  `SVTEST(apb_wdata_addr_max_test)
    amba_xaction put_tr = new();

    my_apb_mst.reset_xactor();
    my_apb_mst.start_xactor();

    put_tr.addr = 'haaaa_5555;
    put_tr.write = 1;
    put_tr.data = 'hafff_afff;
    my_apb_mst.cmd_inbox.put(put_tr);

    @(posedge my_apb_if.clk);
    `APB_WEXPECT('haaaa_5555, 1, 1, 0, 'hafff_afff)

    my_apb_mst.stop_xactor();
  `SVTEST_END(apb_wdata_addr_max_test)


  `SVUNIT_TESTS_END

endclass


