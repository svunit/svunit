class test_registry;

  typedef testsuite array_of_testsuite[];


  local testsuite ts = new("__ts");


  function void register(test::builder test_builder, string full_name);
    ts.register(test_builder, full_name);
  endfunction


  function array_of_testsuite get_testsuites();
    return '{ ts };
  endfunction

endclass
