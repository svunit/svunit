module test_registry_unit_test;

  import svunit_stable_pkg::*;
  `include "svunit_stable_defines.svh"

  string name = "test_registry_ut";
  svunit_testcase svunit_ut;


  import svunit::test_registry;
  import svunit::testsuite;
  import svunit::testcase;


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

    `SVTEST(single_test_package)
      test_registry tr = new();
      testsuite testsuites[];
      testcase testcases[];

      tr.register(fake_test_builder::new_instance(), "some_test_package.some_test");

      testsuites = tr.get_testsuites();
      `FAIL_UNLESS(testsuites.size() == 1)

      testcases = testsuites[0].get_testcases();
      `FAIL_UNLESS(testcases.size() == 1)
      `FAIL_UNLESS_STR_EQUAL(testcases[0].get_name(), "some_test_package")
    `SVTEST_END


    `SVTEST(two_test_packages)
      test_registry tr = new();
      testsuite testsuites[];
      testcase testcases[];

      tr.register(fake_test_builder::new_instance(), "some_test_package.some_test");
      tr.register(fake_test_builder::new_instance(), "some_other_test_package.some_test");

      testsuites = tr.get_testsuites();
      `FAIL_UNLESS(testsuites.size() == 1)

      testcases = testsuites[0].get_testcases();
      `FAIL_UNLESS(testcases.size() == 2)
      `FAIL_UNLESS_STR_EQUAL(testcases[0].get_name(), "some_test_package")
      `FAIL_UNLESS_STR_EQUAL(testcases[1].get_name(), "some_other_test_package")
    `SVTEST_END


    `SVTEST(two_tests_under_package__registers_only_one_tc)
      test_registry tr = new();
      testsuite testsuites[];
      testcase testcases[];

      tr.register(fake_test_builder::new_instance(), "some_test_package.some_test");
      tr.register(fake_test_builder::new_instance(), "some_test_package.some_other_test");

      testsuites = tr.get_testsuites();
      `FAIL_UNLESS(testsuites.size() == 1)

      testcases = testsuites[0].get_testcases();
      `FAIL_UNLESS(testcases.size() == 1)
    `SVTEST_END

  `SVUNIT_TESTS_END


  class fake_test_builder extends svunit::test::builder;

    static function fake_test_builder new_instance();
      new_instance = new();
    endfunction


    virtual function svunit::test create();
      // Intentionally empty
    endfunction

  endclass

endmodule
