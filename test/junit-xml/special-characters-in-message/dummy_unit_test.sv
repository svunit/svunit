//###########################################################################
//
//  Copyright 2025 The SVUnit Authors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//###########################################################################

module dummy_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "dummy_ut";
  svunit_testcase svunit_ut;


  function void build();
    svunit_ut = new(name);
  endfunction

  task setup();
    svunit_ut.setup();
  endtask

  task teardown();
    svunit_ut.teardown();
  endtask


  `SVUNIT_TESTS_BEGIN

    `SVTEST(fail_with_less_than_sign_in_message)
      `FAIL_IF_LOG(1, "Message with <")
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
