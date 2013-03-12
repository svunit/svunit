`ifdef uvm_error
`undef uvm_error
`endif

`ifdef uvm_fatal
`undef uvm_fatal
`endif

`define uvm_error(ID,MSG) \
uvm_report_mock::actual_error(MSG, ID);

`define uvm_fatal(ID,MSG) \
uvm_report_mock::actual_fatal(MSG, ID);


class uvm_report_mock;
  local static svunit_uvm_report_mock_expected_actual_container error_messages = new();;
  local static svunit_uvm_report_mock_expected_actual_container error_ids = new();;

  local static svunit_uvm_report_mock_expected_actual_container fatal_messages = new();;
  local static svunit_uvm_report_mock_expected_actual_container fatal_ids = new();;

  static function void setup();
    error_messages.delete();
    error_ids.delete();

    fatal_messages.delete();
    fatal_ids.delete();
  endfunction

  static function int expected_error_cnt();
    return error_messages.expected.size();
  endfunction

  static function int actual_error_cnt();
    return error_messages.actual.size();
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

  static function int expected_fatal_cnt();
    return fatal_messages.expected.size();
  endfunction

  static function int actual_fatal_cnt();
    return fatal_messages.actual.size();
  endfunction

  static function void expect_fatal(string message="",
                                    string id="");
    fatal_messages.expected.push_back(message);
    fatal_ids.expected.push_back(id);
  endfunction

  static function void actual_fatal(string message="",
                                    string id="");
    fatal_messages.actual.push_back(message);
    fatal_ids.actual.push_back(id);
  endfunction

  static function bit verify_complete(/*svunit_testcase tc = null*/);
    return (error_messages.verify_complete() && error_ids.verify_complete() &&
            fatal_messages.verify_complete() && fatal_ids.verify_complete());
  endfunction
endclass
