`include "svunit_defines.svh"
`include "dut.sv"
`include "clk_and_reset.svh"

module dut_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "dut_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  `CLK_RESET_FIXTURE(5,20)

  logic psel;
  logic penable;
  logic [7:0] paddr;
  logic pwrite;
  logic [31:0] pwdata;
  logic pready;

  dut uut();

  `include "write.svh"

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    pready = 0;
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask

  always @(negedge clk) begin
    $display("%0b %0b 0x%0x %0b 0x%0x %0b", psel, penable, paddr, pwrite, pwdata, pready);
  end

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

  `SVTEST(write1)
    fork
      begin
        write('h11, 'h99);
        step(10);
      end
      begin
        #1;
        while ((penable && psel) !== 1) begin
          @(posedge clk);
          #1;
        end
        @(posedge clk);
        #1 pready = 1;
        @(posedge clk);
        #1 pready = 0;
      end
    join
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
