class testsuite extends svunit_testsuite;

  typedef testcase array_of_testcase[];


  function new(string name);
    super.new(name);
  endfunction


  function void register(test::builder test_builder, string full_name);
    string name_parts[] = string_utils::split_by_char(".", full_name);
    if (name_parts.size() != 2)
      $fatal(0, "Internal error");

    if (!has_testcase(name_parts[0])) begin
      testcase tc = new(name_parts[0]);
      add_testcase(tc);
    end
  endfunction


  local function bit has_testcase(string name);
    foreach (list_of_testcases[i])
      if (list_of_testcases[i].get_name() == name)
        return 1;
    return 0;
  endfunction


  function array_of_testcase get_testcases();
    testcase result[$];

    foreach (list_of_testcases[i]) begin
      testcase tc;
      if (!$cast(tc, list_of_testcases[i]))
        $fatal(0, "Internal error");
      result.push_back(tc);
    end

    return result;
  endfunction

endclass
