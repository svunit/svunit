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


/*
  Macro: `FAIL_IF
  Fails if expression is true

  Parameters: 
    exp - expression to evaluate
*/
`ifndef FAIL_IF
`define FAIL_IF(exp) \
  if (svunit_ut.fail_if(exp, `"exp`", `__FILE__, `__LINE__)) begin \
    if (svunit_ut.is_running) svunit_ut.give_up(); \
  end
`endif


/*
  Macro: `FAIL_UNLESS
  Fails if expression is not true

  Parameters: 
    exp - expression to evaluate
*/
`ifndef FAIL_UNLESS
`define FAIL_UNLESS(exp) \
  if (svunit_ut.fail_unless(exp, `"exp`", `__FILE__, `__LINE__)) begin \
    if (svunit_ut.is_running) svunit_ut.give_up(); \
  end
`endif


/*
  Macro: `INFO
  Displays info message to screen and in log file

  Parameters: 
    msg - string to display
*/
`ifdef VMM
  `define INFO(msg) \
    `vmm_note(log, msg);
`else
  `ifdef AVM
    `define INFO(msg) \
      avm_report_info(msg);
  `else
    `ifdef OVM
      `define INFO(msg) \
        ovm_report_info(msg);
    `else
      `define INFO(msg) \
        $display("INFO:  [%0t][%0s]: %s", $time, name, msg) 
    `endif
  `endif
`endif


/*
  Macro: `ERROR
  Displays error message to screen and in log file

  Parameters: 
    msg - string to display
*/
`ifdef VMM
  `define ERROR(msg) \
    `vmm_error(log, msg);
`else
  `ifdef AVM
    `define ERROR(msg) \
      avm_report_error(msg);
  `else
    `ifdef OVM
      `define ERROR(msg) \
        ovm_report_error(msg);
    `else
      `define ERROR(msg) \
        $display("ERROR: [%0t][%0s]: %s", $time, name, msg)
    `endif
  `endif
`endif


/*
  Macro: `LF
  Displays a blank line in log file  
*/
`define LF $display("");


/*
  Macro: `SVUNIT_TESTS_BEGIN
  START a block of unit tests
*/
`define SVUNIT_TESTS_BEGIN \
  task automatic run(); \
    `INFO($psprintf("%s::RUNNING", name));



/*
  Macro: `SVUNIT_TESTS_END
  END a block of unit tests
*/
`define SVUNIT_TESTS_END endtask

/*
  Macro: `SVTEST
  START an svunit test within an SVUNIT_TEST_BEGIN/END block

  REQUIRES ACCESS TO error_count
*/
`define SVTEST(_NAME_) \
  begin : _NAME_ \
    integer local_error_count = svunit_ut.get_error_count(); \
    string fileName; \
    int lineNumber; \
\
    `INFO($psprintf(`"%s::_NAME_::RUNNING`", name)); \
    setup(); \
    svunit_ut.is_running = 1; \
    fork \
      begin \
        fork \
          begin

/*
  Macro: `SVTEST_END
  END an svunit test within an SVUNIT_TEST_BEGIN/END block
*/
`define SVTEST_END(_NAME_) \
          end \
          begin \
            if (svunit_ut.get_error_count() == local_error_count) begin \
              svunit_ut.wait_for_error(); \
            end \
          end \
        join_any \
        disable fork; \
      end \
    join \
    svunit_ut.is_running = 0; \
    teardown(); \
    if (svunit_ut.get_error_count() == local_error_count) \
      `INFO($psprintf(`"%s::_NAME_::PASSED`", name)); \
    else \
      `INFO($psprintf(`"%s::_NAME_::FAILED`", name)); \
    svunit_ut.update_exit_status(); \
  end : _NAME_
