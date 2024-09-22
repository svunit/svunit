module some_unit_test;
  svunit_pkg::svunit_testcase svunit_ut;
  `include "svunit_defines.svh"

  string name = "some_ut";

  bit clk;

  default clocking @(posedge clk);
  endclocking

  always
    #1 clk = ~clk;


  function void build();
    svunit_ut = new(name);
  endfunction


  task setup();
    svunit_ut.setup();
  endtask


  task teardown();
    svunit_ut.teardown();
  endtask


  `SVUNIT_TESTS_BEGIN

    `SVTEST(can_use_expect)
      expect (1)
        `INFO("As expected");
      else
        `FAIL_IF(1)
    `SVTEST_END

  `SVUNIT_TESTS_END
endmodule
