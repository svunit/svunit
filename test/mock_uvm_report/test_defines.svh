`define TEST_SET(TYPE) \
  `SVTEST(expect_``TYPE) \
    uvm_report_mock::expect_``TYPE(); \
    `FAIL_IF(uvm_report_mock::expected_cnt() != 1); \
  `SVTEST_END() \
  \
  \
  `SVTEST(actual_``TYPE) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    `FAIL_IF(uvm_report_mock::actual_cnt() != 1); \
  `SVTEST_END() \
  \
  \
  `SVTEST(incomplete_w_expected_``TYPE) \
    uvm_report_mock::expect_``TYPE(); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  `SVTEST(incomplete_w_actual_``TYPE) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  `SVTEST(complete_w_actual_and_expected_``TYPE) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    uvm_report_mock::expect_``TYPE("id", "message"); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  /* We are not expecting any specific message or id */ \
  /* so any actual message or id is valid */ \
  `SVTEST(actual_string_expect_null_``TYPE) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    uvm_report_mock::expect_``TYPE(); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  /* We are not expecting any specific id */ \
  /* so any actual id is valid */ \
  `SVTEST(actual_string_expect_null_id_``TYPE) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    uvm_report_mock::expect_``TYPE("", "message"); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  /* We are not expecting any specific message */ \
  /* so any actual message is valid */ \
  `SVTEST(actual_string_expect_null_message_``TYPE) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    uvm_report_mock::expect_``TYPE("id", ""); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  /* We are specifically flagging the wrong id reported */ \
  `SVTEST(actual_string_expect_``TYPE``_wrong_id) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    uvm_report_mock::expect_``TYPE("wrong_id", "message"); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  /* We are specifically flagging the wrong message reported */ \
  `SVTEST(actual_string_expect_``TYPE``_wrong_message) \
    uvm_report_``TYPE("id", "message");  /* actual */ \
    uvm_report_mock::expect_``TYPE("id", "wrong_message"); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  /* We are specifically flagging the wrong severity reported */ \
  `SVTEST(actual_string_expect_``TYPE``_wrong_severity) \
    uvm_report_info("id", "message");  /* actual */ \
    uvm_report_mock::expect_``TYPE("id", "wrong_message"); \
    `FAIL_IF(uvm_report_mock::verify_complete()); \
  `SVTEST_END() \
  \
  \
  `SVTEST(complete_w_macro_actual_and_expected_``TYPE) \
    my_basic.actual_``TYPE(); \
    uvm_report_mock::expect_``TYPE("my_basic", `"TYPE message`"); \
    `FAIL_IF(!uvm_report_mock::verify_complete()); \
  `SVTEST_END()

