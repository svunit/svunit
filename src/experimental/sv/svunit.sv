package svunit;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  `include "full_name_extraction.svh"
  `include "test.svh"
  `include "testcase_for_all_registered_tests.svh"

  `include "testcase.svh"
  `include "testsuite.svh"
  `include "test_registry.svh"


  test_registry __test_registry = new();


  task automatic run_all_tests();
    svunit_testrunner svunit_tr = new("testrunner");
    testsuite testsuites[] = __test_registry.get_testsuites();

    foreach (testsuites[i])
      svunit_tr.add_testsuite(testsuites[i]);

    foreach (testsuites[i]) begin
      testcase testcases[] = testsuites[i].get_testcases();

      testsuites[i].run();
      foreach (testcases[j])
        testcases[j].run();
      testsuites[i].report();
    end

    svunit_tr.report();
  endtask

endpackage
