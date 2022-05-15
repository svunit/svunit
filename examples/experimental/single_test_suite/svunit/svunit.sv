package svunit;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  `include "test.svh"
  `include "testcase_for_all_registered_tests.svh"


  task automatic run_all_tests();
    svunit_testrunner svunit_tr;
    svunit_testsuite svunit_ts;
    testcase_for_all_registered_tests svunit_tc;

    svunit_tr = new("testrunner");
    svunit_ts = new("__ts");
    svunit_tc = new("__tc", test::get_test_builders());  // TODO Should get name from package where tests are defined
    svunit_ts.add_testcase(svunit_tc);
    svunit_tr.add_testsuite(svunit_ts);

    svunit_ts.run();
    svunit_tc.run();
    svunit_ts.report();
    svunit_tr.report();
  endtask

endpackage
