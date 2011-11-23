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
  Class: svunit_testsuite
  Base class for the test suite
*/
class svunit_testsuite;

  /*
    String: name
    Name of class instance
  */
  protected string name;


  /*
    Boolean: run_suite
    Run this suite or not
  */
  local boolean_t run_suite = TRUE;


  /*
    Array: list_of_svunits
    Queue list of Unit Tests to include for this Test Suite
  */
  local svunit_testcase list_of_svunits[$];


  /*
    Variable: success
    Contains Pass or Fail for success of the unit test
  */
  local results_t success = PASS;


  extern function new(string name);
  extern task run();
  extern task load_testcase(svunit_testcase svunit);
  extern task report();

  extern function void add_testcase(svunit_testcase svunit);
  extern function void add_testcases(svunit_testcase svunits[]);

  extern task enable_suite();
  extern task disable_suite();

  extern function string    get_name();
  extern function boolean_t get_runstatus();
  extern function results_t get_results();

endclass


/*
  Constructor: new
  Initializes the test suite

  Parameters:
    name - instance name of the unit test
*/
function svunit_testsuite::new(string name);
  this.name = name;
endfunction


/*
  Method: add_testcase
  Adds single testcase to list of tests

  Parameters:
    svunit - unit test to add to the list of unit tests
*/
function void svunit_testsuite::add_testcase(svunit_testcase svunit);
  if (run_suite == TRUE && svunit.get_runstatus() == TRUE)
  begin
    `INFO($psprintf("Registering Unit Testcase %s", svunit.get_name()));
    list_of_svunits.push_back(svunit); 
  end
endfunction


/*
  Method: add_testcase
  Adds list of testcases to list of tests

  Parameters:
    svunit - list of unit tests to add to the list of unit tests
*/
function void svunit_testsuite::add_testcases(svunit_testcase svunits[]);
  foreach(svunits[i])
    add_testcase(svunits[i]);
endfunction


/*
  Method: disable_suite
  Disables running of the Test Suite
*/
task svunit_testsuite::disable_suite();
  `INFO($psprintf("Disabling Test Suite %0s", name));
  run_suite = FALSE;
endtask


/*
  Method: enable_suite
  Enables running of the Test Suite
*/
task svunit_testsuite::enable_suite();
  `INFO($psprintf("Enabling Test Suite %0s", name));
  run_suite = TRUE;
endtask


/*
  Function: get_name
  Returns instance name of the unit test
*/
function string svunit_testsuite::get_name();
  return name;
endfunction


/*
  Function: get_runstatus
  Returns run_suite variable which determines whether to run this suite or not
*/
function boolean_t svunit_testsuite::get_runstatus();
  return run_suite;
endfunction


/*
  Function: get_results
  Returns success of the unit test case
*/
function results_t svunit_testsuite::get_results();
  return success;
endfunction


/*
  Method: load_testcase
  Calls setup, run, and teardown of the individual unit testcases

  Parameters:
    svunit - unit test to load and run
*/
task svunit_testsuite::load_testcase(svunit_testcase svunit);
  svunit.run();
endtask


/*
  Method: report
  This task reports the results for the unit tests
*/
task svunit_testsuite::report();
  int i;
  `LF;
  `INFO($psprintf("Results for Test Suite %0s", name));
  foreach(list_of_svunits[i])
  begin
    if (list_of_svunits[i].get_runstatus() == TRUE)
    begin
      list_of_svunits[i].report();
      if (list_of_svunits[i].get_results() == FAIL)
        success = FAIL;
    end
  end
endtask


/*
  Method: run
  Main Run Task of the Test Suite
*/
task svunit_testsuite::run();
  if (run_suite == TRUE)
  begin
    `LF;
    `INFO($psprintf("Running Suite: %0s", name));
    foreach(list_of_svunits[i])
    begin
      if (list_of_svunits[i].get_runstatus() == TRUE)
        load_testcase(list_of_svunits[i]);
    end
  end
endtask


