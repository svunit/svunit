package svunit;

  class test;

    protected static string test_names[$];

    protected static function bit register_test_name(string test_name);
      test_names.push_back(test_name);
      return 1;
    endfunction

  endclass

endpackage
