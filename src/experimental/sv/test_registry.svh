class test_registry;

  typedef testsuite array_of_testsuite[];


  local testsuite ts = new("__ts");


  function void register(test::builder test_builder, string full_name);
    string testcase_and_test_name = full_name;
    string name_parts[] = string_utils::split_by_char(".", full_name);

    if (name_parts.size() > 3)
      $fatal(0, "This level of nesting is not yet supported");

    if (name_parts.size() > 2) begin
      testcase_and_test_name = { name_parts[1], ".", name_parts[2] };
    end

    ts.register(test_builder, testcase_and_test_name);
  endfunction


  function array_of_testsuite get_testsuites();
    return '{ ts };
  endfunction

endclass
