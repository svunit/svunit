package svunit;

  typedef string string_darray[];


  class test;

    protected static string test_names[$];

    protected static function bit register_test_name(string test_name);
      test_names.push_back(test_name);
      return 1;
    endfunction

    static function string_darray get_test_names();
      return test_names;
    endfunction

  endclass


  function automatic void run_all_tests();
    string test_names[] = test::get_test_names();
    $display("Found the following tests:");
    foreach (test_names[i])
      $display("  %s", test_names[i]);
  endfunction

endpackage
