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
    virtual function string name(); \
      return `"TEST_NAME`"; \
    endfunction \
    \
    virtual task run(); \


`define TEST_END \
    endtask \
  endclass \


`define TEST_F_BEGIN(TEST_FIXTURE, TEST_NAME) \
  class TEST_NAME extends TEST_FIXTURE; \
    local static const bit is_test_builder_registerd \
        = register_test_builder(concrete_builder#(TEST_NAME)::get()); \
    local static string full_name_of_class = $sformatf("%m"); \
    \
    virtual function string full_name(); \
      return full_name_of_class; \
    endfunction \
    \
    virtual function string name(); \
      return `"TEST_NAME`"; \
    endfunction \
    \
    virtual task run(); \


`define TEST_F_END \
    endtask \
  endclass \
