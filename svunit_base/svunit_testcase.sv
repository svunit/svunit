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
  Class: svunit_testcase
  Base class for the unit testcase
*/
virtual class svunit_testcase;


  /*
    String: name
    Name of class instance
  */
  protected string name;


  /*
    Boolean: run_ut
    Enables the unit test to run
  */
  local boolean_t run_ut = TRUE;



  /*
    Boolean: verbose
    Increase verbosity of messages
  */
  local boolean_t verbose = FALSE;


  /*
    uint: error_count
    Counter for number of errors
  */
  local int unsigned error_count = 0;


  /*
    Variable: success
    Contains Pass or Fail for success of the unit test
  */
  local results_t success;


  extern function new(string name);

  `ifdef VCS 
    extern virtual protected task setup();
  `else
    pure   virtual protected task setup();
  `endif

  extern virtual protected task run_test();

  extern virtual protected task svunit_tests();

  extern virtual protected task teardown();

  extern task run();
  extern task report();

  extern local task pass(string s);
  extern local task fail(string s);

  extern protected task fail_if(bit b, string s);
  extern protected task fail_unless(bit b, string s);

  extern task enable_verbose();
  extern task disable_verbose();

  extern task enable_unit_test();
  extern task disable_unit_test();

  extern function string    get_name();
  extern function boolean_t get_runstatus();
  extern function results_t get_results();

endclass


/*
  Constructor: new
  Initializes the unit test

  Parameters:
    name - instance name of the unit test

*/
function svunit_testcase::new(string name);
  this.name = name;
endfunction


/*
  Method: disable_unit_test
  Disbles the unit test from running
*/
task svunit_testcase::disable_unit_test();
  run_ut = FALSE;
endtask


/*
  Method: disable_verbose 
  Disbles verbose mode
*/
task svunit_testcase::disable_verbose();
  verbose = FALSE;
endtask


/*
  Method: enable_unit_test
  Enables the unit test from running
*/
task svunit_testcase::enable_unit_test();
  run_ut = TRUE;
endtask


/*
  Method: enable_verbose 
  Enables verbose mode
*/
task svunit_testcase::enable_verbose();
  verbose = TRUE;
endtask


/*
  Method: fail
  Increments Test Result's error count and displays message
  
  Parameters:
    s - display statement to print out
*/
task svunit_testcase::fail(string s);
  error_count++;
  `ERROR($psprintf("%s: FAIL", s));
endtask


/*
  Method: fail_if
  calls fail if expression is true

  Parameters:
    b - evaluation of expression (0 - false, 1 - true)
    s - string to pass to pass or fail task
*/
task svunit_testcase::fail_if(bit b, string s);
  if (b)
    fail($psprintf("fail_if: %s", s));
  else
    pass($psprintf("fail_if: %s", s));
endtask


/*
  Method: fail_unless
  calls fail if expression is not true

  Parameters:
    b - evaluation of expression (0 - false, 1 - true)
    s - string to pass to pass or fail task
*/
task svunit_testcase::fail_unless(bit b, string s);
  if (!b)
    fail($psprintf("fail_unless: %s", s));
  else
    pass($psprintf("fail_unless: %s", s));
endtask


/*
  Function: get_name
  Returns instance name of the unit test
*/
function string svunit_testcase::get_name();
  return name;
endfunction


/*
  Function: get_results
  Returns success of the unit test case
*/
function results_t svunit_testcase::get_results();
  return success;
endfunction


/*
  Function: get_runstatus
  Returns run_suite variable which determines whether to run this suite or not
*/
function boolean_t svunit_testcase::get_runstatus();
  return run_ut;
endfunction


/*
  Method: pass 
  If verbose is true, print out display statement from argument
  
  Parameters:
    s - display statement to print out
*/
task svunit_testcase::pass(string s);
  if (verbose == TRUE)
    `INFO($psprintf("%s: PASS", s));
endtask


/*
  Method: report
  This task reports the results for the unit tests
*/  
task svunit_testcase::report();
  if (success == PASS)
    `INFO($psprintf("Unit Test %0s: PASS", name));
  else
    `ERROR($psprintf("Unit Test %0s: FAIL", name));
endtask


/*
  Method: run
  Main run task for the unit test
*/
task svunit_testcase::run();
  setup();
  run_test();
  teardown();
endtask


/*
  Method: run_test
  execute the list of registered unit tests 
*/
task svunit_testcase::run_test();
  `INFO($psprintf("Running Unit Tests for class %s", name));
  svunit_tests();
endtask


/*
  Method: svunit_tests
  invoke the unit tests registed with the SVUNIT_TEST_BEGIN/END macros
*/
task svunit_testcase::svunit_tests();
endtask


/*
  Method: setup
  Only required if using VCS since pure virtual functions are not implemented
*/
`ifdef VCS
  task svunit_testcase::setup();
  endtask
`endif


/*
  Method: teardown
  Registers test as passed or failed
*/
task svunit_testcase::teardown();
  if (error_count == 0)
    success = PASS;
  else
    success = FAIL;
endtask


