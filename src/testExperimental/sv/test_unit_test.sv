module test_unit_test;

  import svunit_stable_pkg::*;
  `include "svunit_stable_defines.svh"

  string name = "test_ut";
  svunit_testcase svunit_ut;


  import svunit::test;

  typedef class fake_test;


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

    `SVTEST(run_calls_test_body)
      fake_test t = new();
      t.run();
      `FAIL_UNLESS_EQUAL(t.num_test_body_calls, 1)
    `SVTEST_END


    `SVTEST(run_calls_set_up)
      fake_test t = new();
      t.run();
      `FAIL_UNLESS_EQUAL(t.num_set_up_calls, 1)
    `SVTEST_END


    `SVTEST(run_calls_tear_down)
      fake_test t = new();
      t.run();
      `FAIL_UNLESS_EQUAL(t.num_tear_down_calls, 1)
    `SVTEST_END

  `SVUNIT_TESTS_END


  class fake_test extends test;

    int unsigned num_test_body_calls;
    int unsigned num_set_up_calls;
    int unsigned num_tear_down_calls;

    protected virtual task set_up();
      num_set_up_calls++;
    endtask

    virtual task test_body();
      num_test_body_calls++;
    endtask

    protected virtual task tear_down();
      num_tear_down_calls++;
    endtask

    virtual function string name();
      return "fake_test";
    endfunction

    virtual function string full_name();
      return "fake_test";
    endfunction

  endclass

endmodule
