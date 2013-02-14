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

  static function void expect_error(string message="",
                                    string id="");
    _expected_error_message.push_back(message);
    _expected_error_id.push_back(id);
  endfunction

  static function void actual_error(string message="",
                                    string id="");
    _actual_error_message.push_back(message);
    _actual_error_id.push_back(id);
  endfunction

  static function bit verify_complete(/*svunit_testcase tc = null*/);
    if (expected_error_cnt() != actual_error_cnt()) begin
      return 0;
    end

    foreach (_expected_error_message[i]) begin
      if (!error_message_match_at_idx(i)) return 0;
      else if (!error_id_match_at_idx(i)) return 0;
    end

    return 1;
  endfunction

  local static function bit error_message_match_at_idx(int i);
    if (expect_message_at_idx(i)) return message_matches_at_idx(i);
    else return 1;
  endfunction

  local static function bit expect_message_at_idx(int i);
    return (_expected_error_message[i] != "");
  endfunction

  local static function bit message_matches_at_idx(int i);
    return (_expected_error_message[i] == _actual_error_message[i]);
  endfunction

  local static function bit error_id_match_at_idx(int i);
    if (expect_id_at_idx(i)) return id_matches_at_idx(i);
    else return 1;
  endfunction

  local static function bit expect_id_at_idx(int i);
    return (_expected_error_id[i] != "");
  endfunction

  local static function bit id_matches_at_idx(int i);
    return (_expected_error_id[i] == _actual_error_id[i]);
  endfunction
endclass
