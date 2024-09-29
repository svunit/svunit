class testcase extends svunit_testcase;

  typedef test::builder array_of_test_builder[];


  local test::builder test_builders[$];
  local test tests[$];


  function new(string name);
    super.new(name);
  endfunction


  function void register(test::builder test_builder);
    test_builders.push_back(test_builder);
  endfunction


  function array_of_test_builder get_test_builders();
    return test_builders;
  endfunction


  // FIXME Get tests to work again
  /*
  `SVUNIT_TESTS_BEGIN
    foreach (test_builders[i]) begin
      test t = test_builders[i].create();
      tests.push_back(t);
    end
    foreach (tests[i]) begin
      string test_name = tests[i].name();
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
        fork
          begin
            fork
              begin
                tests[i].run();
      `SVTEST_END
    end
  `SVUNIT_TESTS_END
  */

endclass
