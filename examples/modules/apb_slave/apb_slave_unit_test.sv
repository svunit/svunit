import svunit_pkg::*;

`include "svunit_defines.svh"
`include "apb_slave.sv"
typedef class c_apb_slave_unit_test;

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

  reg clk;
  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end
    

  apb_slave my_apb_slave(.clk(clk),
                         .rst_n(my_apb_slave_if.rst_n),
                         .paddr(my_apb_slave_if.paddr),
                         .pwrite(my_apb_slave_if.pwrite),
                         .psel(my_apb_slave_if.psel),
                         .penable(my_apb_slave_if.penable),
                         .pwdata(my_apb_slave_if.pwdata),
                         .prdata(my_apb_slave_if.prdata));

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
    /* Place Setup Code Here */
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
  //   write without psel asserted during setup
  //************************************************************
  `SVTEST(write_wo_psel)
    addr = 'h32;
    data = 'h61;

    write(addr, data);
    write(addr, 'hff, 0);
    read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SVTEST_END(write_wo_psel)


  //************************************************************
  // Test:
  //   write_wo_write
  //
  // Desc:
  //   do a write then a read at the same address but insert a
  //   write without pwrite asserted during setup
  //************************************************************
  `SVTEST(write_wo_write)
    addr = 'h32;
    data = 'h61;

    write(addr, data);
    write(addr, 'hff, 1, 0);
    read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SVTEST_END(write_wo_write)


  `SVUNIT_TESTS_END


  task write(logic [7:0] addr, logic [31:0] data, logic setup_psel = 1, logic setup_write = 1);
    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = 0;
    my_apb_slave_if.penable = 0;

    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = setup_psel;
    my_apb_slave_if.pwrite = setup_write;
    my_apb_slave_if.paddr = addr;
    my_apb_slave_if.pwdata = data;
    my_apb_slave_if.penable = 0;

    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.pwrite = 1;
    my_apb_slave_if.penable = 1;
    my_apb_slave_if.psel = 1;

    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = 0;
    my_apb_slave_if.pwrite = 0;
    my_apb_slave_if.penable = 0;
  endtask


  task read(logic [7:0] addr, output logic [31:0] data);
    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = 0;
    my_apb_slave_if.penable = 0;

    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.psel = 1;
    my_apb_slave_if.paddr = addr;
    my_apb_slave_if.penable = 0;

    @(negedge my_apb_slave_if.clk);
    my_apb_slave_if.penable = 1;

    @(negedge my_apb_slave_if.clk);
    data = my_apb_slave_if.prdata;
    my_apb_slave_if.psel = 0;
    my_apb_slave_if.penable = 0;
  endtask

endclass


