package svunit;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  virtual class test;

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

    pure virtual task run();

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

    `SVUNIT_TESTS_BEGIN
      foreach (tests[i]) begin
        string test_name = $vtypename(tests[i]);
        svunit_testcase svunit_ut = this;

        // More or less what `SVTEST expands to
        if (svunit_pkg::_filter.is_selected(svunit_ut, test_name)) begin
          string _testName = test_name;
          integer local_error_count = svunit_ut.get_error_count();
          string fileName;
          int lineNumber;
          `INFO($sformatf(`"%s::RUNNING`", _testName));
          svunit_pkg::current_tc = svunit_ut;
          svunit_ut.add_junit_test_case(_testName);
          svunit_ut.start();
          setup();
          fork
            begin
              fork
                begin
                  tests[i].run();
        `SVTEST_END
      end
    `SVUNIT_TESTS_END

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
