typedef class global_test_registry;


virtual class test;

  typedef class builder;


  protected static function bit register_test_builder(builder b, string typename);
    full_name_extraction fn_extraction = new();
    string full_name = fn_extraction.get_full_name(typename);
    global_test_registry::get().register(b, full_name);

    return 1;
  endfunction


  pure virtual function string name();


  task run();
    set_up();
    test_body();
    tear_down();
  endtask


  protected virtual task set_up();
  endtask


  pure virtual protected task test_body();


  protected virtual task tear_down();
  endtask


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
