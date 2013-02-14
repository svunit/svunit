class svunit_uvm_report_mock_expected_actual_container;
  string expected [$];
  string actual [$];

  function void delete();
    expected.delete();
    actual.delete();
  endfunction

  function bit valid_at_idx(int i);
    if (expect_at_idx(i)) return match_at_idx(i);
    else return 1;
  endfunction
  
  local function bit expect_at_idx(int i);
    return (expected[i] != "");
  endfunction
  
  local function bit match_at_idx(int i);
    return (expected[i] == actual[i]);
  endfunction

  function bit verify_complete();
    if (expected.size() != actual.size()) begin
      return 0;
    end

    foreach (expected[i]) if (!valid_at_idx(i)) return 0;

    return 1;
  endfunction
endclass

