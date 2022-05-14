package svunit;

  import svunit_pkg::*;

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


  class testcase_for_all_registered_tests extends svunit_testcase;

    local test tests[$];

    function new(string name, test::builder test_builders[]);
      super.new(name);
      foreach (test_builders[i]) begin
        test t = test_builders[i].create();
        tests.push_back(t);
      end
    endfunction


    function void run();
      // TODO Implement
      $display("Would run:");
      foreach (tests[i])
        $display("  ", $vtypename(tests[i]));
    endfunction

  endclass


  task automatic run_all_tests();
    svunit_testrunner svunit_tr;
    svunit_testsuite svunit_ts;
    testcase_for_all_registered_tests svunit_tc;

    svunit_tr = new("testrunner");
    svunit_ts = new("__ts");
    svunit_tc = new("__tc", test::get_test_builders());  // TODO Should get name from package where tests are defined
    svunit_ts.add_testcase(svunit_tc);
    svunit_tr.add_testsuite(svunit_ts);

    svunit_ts.run();
    svunit_tc.run();
    svunit_ts.report();
    svunit_tr.report();
  endtask

endpackage
