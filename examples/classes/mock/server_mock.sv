//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################


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
