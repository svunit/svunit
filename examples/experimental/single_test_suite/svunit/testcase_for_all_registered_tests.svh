class testcase_for_all_registered_tests extends svunit_testcase;

  local test tests[$];


  function new(string name, test::builder test_builders[]);
    super.new(name);
    foreach (test_builders[i]) begin
      test t = test_builders[i].create();
      tests.push_back(t);
    end
  endfunction


  `SVUNIT_TESTS_BEGIN
    foreach (tests[i]) begin
      string test_name = $vtypename(tests[i]);
      svunit_testcase svunit_ut = this;

      // More or less what `SVTEST expands to
      if (svunit_pkg::_filter.is_selected(svunit_ut, test_name)) begin
        string _testName = test_name;
        integer local_error_count = svunit_ut.get_error_count();
        string fileName;
        int lineNumber;
        `INFO($sformatf(`"%s::RUNNING`", _testName));
        svunit_pkg::current_tc = svunit_ut;
        svunit_ut.add_junit_test_case(_testName);
        svunit_ut.start();
        setup();
        fork
          begin
            fork
              begin
                tests[i].run();
      `SVTEST_END
    end
  `SVUNIT_TESTS_END

endclass
