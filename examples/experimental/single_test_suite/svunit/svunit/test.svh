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


  pure virtual function string full_name();
  pure virtual function string name();


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
