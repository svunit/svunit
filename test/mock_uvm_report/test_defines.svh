`define TEST_SET(TYPE) \
  `SVTEST(expect_``TYPE) \
    uvm_report_mock::expect_``TYPE(); \
    `FAIL_IF(uvm_report_mock::expected_``TYPE``_cnt() != 1); \
  `SVTEST_END(expect_``TYPE) \
  \
  \
  `SVTEST(actual_``TYPE) \
    uvm_report_mock::actual_``TYPE(); \
    `FAIL_IF(uvm_report_mock::actual_``TYPE``_cnt() != 1); \
  `SVTEST_END(actual_``TYPE) \
  \
  \
  `SVTEST(incomplete_w_expected_``TYPE) \
    uvm_report_mock::expect_``TYPE(); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END(incomplete_w_expected_``TYPE) \
  \
  \
  `SVTEST(incomplete_w_actual_``TYPE) \
    uvm_report_mock::actual_``TYPE(); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END(incomplete_w_actual_``TYPE) \
  \
  \
  `SVTEST(complete_w_actual_and_expected_``TYPE) \
    uvm_report_mock::actual_``TYPE(); \
    uvm_report_mock::expect_``TYPE(); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END(complete_w_actual_and_expected_``TYPE) \
  \
  \
  `SVTEST(actual_string_expect_null_``TYPE) \
    uvm_report_mock::actual_``TYPE("MESSAGE", "ID"); \
    uvm_report_mock::expect_``TYPE(); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END(actual_string_expect_null_``TYPE) \
  \
  \
  `SVTEST(actual_string_expect_``TYPE``_wrong_message) \
    uvm_report_mock::actual_``TYPE("MESSAGE"); \
    uvm_report_mock::expect_``TYPE("wrong_MESSAGE"); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END(actual_string_expect_``TYPE``_wrong_message) \
  \
  \
  `SVTEST(actual_string_expect_``TYPE``_wrong_id) \
    uvm_report_mock::actual_``TYPE("MESSAGE", "ID"); \
    uvm_report_mock::expect_``TYPE("MESSAGE", "wrong_ID"); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END(actual_string_expect_``TYPE``_wrong_id) \
  \
  `SVTEST(complete_w_macro_actual_and_expected_``TYPE) \
    my_basic.actual_``TYPE(); \
    uvm_report_mock::expect_``TYPE("TYPE message", "my_basic"); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END(complete_w_macro_actual_and_expected_``TYPE) \
