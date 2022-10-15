class test_registry;

  typedef testsuite array_of_testsuite[];


  local testsuite ts = new("__ts");


  function void register(test::builder test_builder, string full_name);
    string name_parts[] = string_utils::split_by_char(".", full_name);
    testcase tc = new(name_parts[0]);
    ts.add_testcase(tc);
  endfunction


  function array_of_testsuite get_testsuites();
    return '{ ts };
  endfunction

endclass
