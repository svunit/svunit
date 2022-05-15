`define TEST_BEGIN(TEST_NAME) \
  class TEST_NAME extends svunit::test; \
    local static const bit is_test_builder_registerd \
        = register_test_builder(concrete_builder#(TEST_NAME)::get()); \
    local static string full_name_of_class = $sformatf("%m"); \
    \
    virtual function string full_name(); \
      return full_name_of_class; \
    endfunction \
    \
    virtual task run(); \


`define TEST_END \
    endtask \
  endclass \
