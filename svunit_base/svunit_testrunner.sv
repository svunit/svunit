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
  Class: svunit_testrunner
  Base class for the test runner
*/
class svunit_testrunner;

  /*
    String: name
    Name of class instance
  */
  protected string name;


  /*
    Array: list_of_svunits
    Queue List of Test Suites to include in the Test Runner
  */
  local svunit_testsuite list_of_suites[$];


  /*
    Variable: success
    Contains Pass or Fail for success of the unit test
  */
  local results_t success = PASS;


  extern function new(string name);
  extern function void add_testsuite(svunit_testsuite suite);
  extern task report();
  extern function string get_name();

endclass


/*
  Constructor: name
  Initializes the test suite

  Parameters:
    name - instance name of the unit test
*/
function svunit_testrunner::new(string name);
  this.name = name;
endfunction


/*
  Method: add_testsuite
  Adds single testsuite to list of suites

  Parameters:
    suite - test suite to add to the list of test suites
*/
function void svunit_testrunner::add_testsuite(svunit_testsuite suite);
  `INFO($psprintf("Registering Test Suite %0s", suite.get_name()));
  list_of_suites.push_back(suite); 
endfunction


/*
  Function: get_name
  Returns instance name of the unit test
*/
function string svunit_testrunner::get_name();
  return name;
endfunction


/*
  Method: report
  This task reports the results for the test suites
*/
task svunit_testrunner::report();
  foreach (list_of_suites[i])
  begin
    if (list_of_suites[i].get_results() == FAIL)
      success = FAIL;
  end

  `LF;

  if (success == PASS)
    `INFO("Testrunner::PASSED");
  else
    `INFO("Testrunner::FAILED");
endtask
