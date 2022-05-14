package svunit;

  class test;

    typedef class builder;
    typedef builder builder_darray[];

    protected static builder test_builders[$];

    protected static function bit register_test_builder(builder b);
      test_builders.push_back(b);
      return 1;
    endfunction

    static function builder_darray get_test_builders();
      return test_builders;
    endfunction

    virtual class builder;
      pure virtual function test create();
    endclass

    class concrete_builder #(type T = test) extends builder;
      local static concrete_builder #(T) single_instance;

      static function concrete_builder #(T) get();
        if (single_instance == null)
          single_instance = new();
        return single_instance;
      endfunction

      virtual function T create();
        T result = new();
        return result;
      endfunction
    endclass

  endclass


  function automatic void run_all_tests();
    test::builder test_builders[] = test::get_test_builders();
    $display("Found the following tests:");
    foreach (test_builders[i]) begin
      test t = test_builders[i].create();
      $display($vtypename(t));
    end
  endfunction

endpackage
