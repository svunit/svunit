class server_mock extends server;
  local action_e perform_actions[$];

  task verify_perform(action_e exp_action);
    `FAIL_UNLESS(perform_actions.size() > 0)
    `FAIL_UNLESS(perform_actions.pop_front() == exp_action)
  endtask

  task verify_no_more_perform();
    `FAIL_IF(perform_actions.size() > 0)
  endtask


  // Stubbed out method
  virtual function void perform(action_e action, int value = 0);
    fork
      `FAIL_IF(action == ACTION1 && value != 0)
    join_none

    perform_actions.push_back(action);
  endfunction
endclass
