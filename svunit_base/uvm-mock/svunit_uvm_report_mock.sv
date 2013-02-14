class expected_actual_container;
  string expected [$];
  string actual [$];
endclass


class uvm_report_mock;
  local static expected_actual_container error_messages = new();;
  local static expected_actual_container error_ids = new();;

  static function void setup();
    error_messages.expected.delete();
    error_ids.expected.delete();

    error_messages.actual.delete();
    error_ids.actual.delete();
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
    if (expected_error_cnt() != actual_error_cnt()) begin
      return 0;
    end

    foreach (error_messages.expected[i]) begin
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
    return (error_messages.expected[i] != "");
  endfunction

  local static function bit message_matches_at_idx(int i);
    return (error_messages.expected[i] == error_messages.actual[i]);
  endfunction

  local static function bit error_id_match_at_idx(int i);
    if (expect_id_at_idx(i)) return id_matches_at_idx(i);
    else return 1;
  endfunction

  local static function bit expect_id_at_idx(int i);
    return (error_ids.expected[i] != "");
  endfunction

  local static function bit id_matches_at_idx(int i);
    return (error_ids.expected[i] == error_ids.actual[i]);
  endfunction
endclass
