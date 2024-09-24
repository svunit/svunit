class testsuite extends svunit_testsuite;

  typedef testcase array_of_testcase[];


  function new(string name);
    super.new(name);
  endfunction


  function void register(test::builder test_builder, string full_name);
    testcase tc;
    string name_parts[] = string_utils::split_by_char(".", full_name);
    if (name_parts.size() != 2)
      $fatal(0, "Internal error");

    tc = get_testcase(name_parts[0]);
    if (tc == null) begin
      tc = new(name_parts[0]);
      add_testcase(tc);
    end

    tc.register(test_builder);
  endfunction


  local function testcase get_testcase(string name);
    foreach (list_of_testcases[i])
      if (list_of_testcases[i].get_name() == name) begin
        testcase tc;
        if (!$cast(tc, list_of_testcases[i]))
          $fatal(0, "Internal error");
        return tc;
      end
    return null;
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
