class uvm_report_mock;
  static svunit_uvm_report_mock_expected_actual_container reports = new();

  static function void setup();
    reports.delete();
  endfunction

  static function int expected_cnt();
    return reports.expected.size();
  endfunction

  static function int actual_cnt();
    return reports.actual.size();
  endfunction

  `define EXPECT_SEVERITY(NAME, SEV) \
    static function void expect_``NAME(string id="", \
                                       string message=""); \
      reports.expected.push_back('{id, message, SEV}); \
    endfunction

  `EXPECT_SEVERITY(warning, UVM_WARNING)
  `EXPECT_SEVERITY(error,   UVM_ERROR)
  `EXPECT_SEVERITY(fatal,   UVM_FATAL)

  static function bit verify_complete();
    return reports.verify_complete();
  endfunction

  static function string dump();
    return reports.dump();
  endfunction
endclass
