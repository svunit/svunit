class testcase extends svunit_testcase;

  typedef test::builder array_of_test_builder[];


  local test::builder test_builders[$];


  function new(string name);
    super.new(name);
  endfunction


  function void register(test::builder test_builder);
    test_builders.push_back(test_builder);
    add_test(test_builder.create().get_adapter());
  endfunction


  function array_of_test_builder get_test_builders();
    return test_builders;
  endfunction

endclass
