class uvm_report_mock;
  local static svunit_uvm_report_mock_expected_actual_container error_messages = new();;
  local static svunit_uvm_report_mock_expected_actual_container error_ids = new();;

  static function void setup();
    error_messages.delete();
    error_ids.delete();
  endfunction

  static function int expected_error_cnt();
    return error_messages.expected.size();
  endfunction

  static function int expected_fatal_cnt();
  endfunction

  static function int actual_error_cnt();
    return error_messages.actual.size();
  endfunction

  static function int actual_fatal_cnt();
  endfunction

  static function void expect_error(string message="",
                                    string id="");
    error_messages.expected.push_back(message);
    error_ids.expected.push_back(id);
  endfunction

  static function void actual_error(string message="",
                                    string id="");
    error_messages.actual.push_back(message);
    error_ids.actual.push_back(id);
  endfunction

  static function bit verify_complete(/*svunit_testcase tc = null*/);
    return (error_messages.verify_complete() && error_ids.verify_complete());
  endfunction
endclass
