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
  extern task report();

  extern function void add_testcase(svunit_testcase svunit);

  extern function string    get_name();
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
  `INFO($psprintf("Registering Unit Testcase %s", svunit.get_name()));
  list_of_svunits.push_back(svunit); 
endfunction


/*
  Function: get_name
  Returns instance name of the unit test
*/
function string svunit_testsuite::get_name();
  return name;
endfunction


/*
  Function: get_results
  Returns success of the unit test case
*/
function results_t svunit_testsuite::get_results();
  return success;
endfunction


/*
  Method: report
  This task reports the results for the unit tests
*/
task svunit_testsuite::report();
  foreach(list_of_svunits[i])
  begin
    list_of_svunits[i].report();
    if (list_of_svunits[i].get_results() == FAIL) begin
      success = FAIL;
    end
  end

  if (success == PASS) `INFO($psprintf("%0s::PASSED", name));
  else                 `INFO($psprintf("%0s::FAILED", name));
endtask


/*
  Method: run
  Main Run Task of the Test Suite
*/
task svunit_testsuite::run();
  `INFO($psprintf("%0s::RUNNING", name));
endtask
