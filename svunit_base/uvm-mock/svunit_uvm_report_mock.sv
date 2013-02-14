class uvm_report_mock;
  local static string _expected_error_message [$];
  local static string _expected_error_id [$];

  local static string _actual_error_message [$];
  local static string _actual_error_id [$];

  static function void setup();
    _expected_error_message.delete();
    _expected_error_id.delete();

    _actual_error_message.delete();
    _actual_error_id.delete();
  endfunction

  static function int expected_error_cnt();
    return _expected_error_message.size();
  endfunction

  static function int expected_fatal_cnt();
  endfunction

  static function int actual_error_cnt();
    return _actual_error_message.size();
  endfunction

  static function int actual_fatal_cnt();
  endfunction

  static function void expect_error(string id="",
                                    string message="");
    _expected_error_message.push_back(message);
    _expected_error_id.push_back(id);
  endfunction

  static function void actual_error(string id="",
                                    string message="");
    _actual_error_message.push_back(message);
    _actual_error_id.push_back(id);
  endfunction

  static function bit verify_complete(/*svunit_testcase tc = null*/);
    return expected_error_cnt() == actual_error_cnt();
  endfunction
endclass
