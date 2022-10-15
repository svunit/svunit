class test_registry;

  typedef testsuite array_of_testsuite[];


  local testsuite testsuites[string];


  function void register(test::builder test_builder, string full_name);
    testsuite ts;
    string name_parts[] = string_utils::split_by_char(".", full_name);
    string testcase_and_test_name = full_name;
    string testsuite_name = name_parts[0];

    if (name_parts.size() > 3)
      $fatal(0, "This level of nesting is not yet supported");

    if (name_parts.size() > 2) begin
      testcase_and_test_name = { name_parts[1], ".", name_parts[2] };
    end

    ts = get_testsuite(testsuite_name);
    ts.register(test_builder, testcase_and_test_name);
  endfunction


  local function testsuite get_testsuite(string name);
    if (!testsuites.exists(name))
      testsuites[name] = new({ name, "_ts" });
    return testsuites[name];
  endfunction


  function array_of_testsuite get_testsuites();
    testsuite result[$];

    foreach (testsuites[name])
      result.push_back(testsuites[name]);

    return result;
  endfunction

endclass
