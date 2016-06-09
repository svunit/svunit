`include "svunit_defines.svh"

`include "server.sv"
`include "client.sv"
`include "server_mock.sv"


module client_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "client_ut";
  svunit_testcase svunit_ut;


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

    `SVTEST(do_something__performs_action0)
      server_mock s = new();
      client c = new(s);
      c.do_something();
      s.verify_perform(server::ACTION0);
    `SVTEST_END

    `SVTEST(do_something_else__not_is_cool__performs_action1)
      server_mock s = new();
      client c = new(s);
      c.do_something_else(0);
      s.verify_perform(server::ACTION1);
    `SVTEST_END

    `SVTEST(do_something_else__is_cool__performs_action1)
      server_mock s = new();
      client c = new(s);
      c.do_something_else(1);
      s.verify_perform(server::ACTION1);
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
