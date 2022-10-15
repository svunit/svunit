class testsuite extends svunit_testsuite;

  typedef testcase array_of_testcase[];


  function new(string name);
    super.new(name);
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
