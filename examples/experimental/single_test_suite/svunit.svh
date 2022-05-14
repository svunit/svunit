`define TEST_BEGIN(TEST_NAME) \
  class TEST_NAME extends svunit::test; \
    local static const bit is_test_name_registerd = register_test_name(`"TEST_NAME`");


`define TEST_END \
  endclass
