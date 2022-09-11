class testcase_for_all_registered_tests extends svunit_testcase;

  typedef test test_darray[];
  typedef string string_darray[];


  local test tests[$];


  function new();
    test tests[] = get_tests(test::get_test_builders());
    string name = get_testcase_name(tests);

    super.new(name);
    this.tests = tests;
  endfunction


  local function test_darray get_tests(test::builder test_builders[]);
    test tests[$];
    foreach (test_builders[i]) begin
      test t = test_builders[i].create();
      tests.push_back(t);
    end
    return tests;
  endfunction


  local function string get_testcase_name(test tests[]);
    string name;
    string parts_of_first_test_name[];

    parts_of_first_test_name = split_by_double_colon(tests[0].full_name());
    if (parts_of_first_test_name.size() != 2)
      $fatal(0, "Expected test names to be of type '<package>::<class>'");

    name = parts_of_first_test_name[0];
    foreach (tests[i]) begin
      string parts_of_test_name[];
      if (i == 0)
        continue;

      parts_of_test_name = split_by_double_colon(tests[i].full_name);
      if (parts_of_test_name[0] != name)
        $fatal(0, "Expected all tests to be defined in the same package");
    end

    return name;
  endfunction


  local static function string_darray split_by_double_colon(string s);
    string parts[$];
    int last_char_position = -1;

    for (int i = 0; i < s.len(); i++) begin
      if (i == s.len()-1)
        parts.push_back(s.substr(last_char_position+1, i));
      if (s.substr(i, i+1) == "::") begin
        parts.push_back(s.substr(last_char_position+1, i-1));
        last_char_position = i + 1;
      end
    end

    return parts;
  endfunction


  `SVUNIT_TESTS_BEGIN
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
        tests[i].set_up();
        fork
          begin
            fork
              begin
                tests[i].test_body();
      `SVTEST_END
    end
  `SVUNIT_TESTS_END

endclass
