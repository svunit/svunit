`define SVUNIT_INTERNAL_TEST_BEGIN(TEST_NAME, BASE_CLASS) \
  class TEST_NAME extends BASE_CLASS; \
    \
    local static const bit is_test_builder_registerd \
        = register_test_builder(concrete_builder#(TEST_NAME)::get(), $typename(TEST_NAME)); \
    \
    \
    virtual function string name(); \
      return `"TEST_NAME`"; \
    endfunction \
    \
    \
    protected virtual task test_body(); \


`define SVUNIT_INTERNAL_TEST_END \
    endtask \
  endclass \
