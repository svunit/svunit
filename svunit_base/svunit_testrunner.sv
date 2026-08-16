//###########################################################################
//
//  Copyright 2011-2023 The SVUnit Authors.
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

/*
  Class: svunit_testrunner
  Base class for the test runner
*/
class svunit_testrunner extends svunit_base;

  /*
    Array: list_of_svunits
    Queue List of Test Suites to include in the Test Runner
  */
  local svunit_testsuite list_of_suites[$];


  /*
    Variable to store seed randomly generated at simulation startup
    This can then be referenced to initialise the RNGs
    in a predictable manner on a per test basis
  */
  local int unsigned     svunit_initial_seed;


  /*
    Interface
  */
  extern function new(string name);
  extern function void add_testsuite(svunit_testsuite suite);
  extern function int unsigned get_initial_seed();

  extern function void report();


  local function int unsigned get_num_passing_testsuites();
    int unsigned result;
    foreach (list_of_suites[i])
      if (list_of_suites[i].get_results() == PASS)
        result++;
    return result;
  endfunction


  local function void write_xml();
    int xml = $fopen("tests.xml", "w");
    junit_xml::TestSuite test_suites[$];
    foreach (list_of_suites[i]) begin
      test_suites.push_back(list_of_suites[i].as_junit_test_suite());
    end
    $fwrite(xml, junit_xml::to_xml_report_string(test_suites));
    $fwrite(xml, "\n");
  endfunction

endclass


/*
  Constructor: name
  Initializes the test runner

  Parameters:
    name - instance name of the unit test runner
*/
function svunit_testrunner::new(string name);
  super.new(name);
  this.svunit_initial_seed = $urandom();
  `INFO($sformatf("Initial svunit seed %0d", this.get_initial_seed()));
endfunction

/*
  Method: get_initial_seed
  Returns the initial seed generated at simulation startup
*/

function int unsigned svunit_testrunner::get_initial_seed();
  return this.svunit_initial_seed;
endfunction

/*
  Method: add_testsuite
  Adds single testsuite to list of suites

  Parameters:
    suite - test suite to add to the list of test suites
*/
function void svunit_testrunner::add_testsuite(svunit_testsuite suite);
  `INFO($sformatf("Registering Test Suite %0s", suite.get_name()));
  list_of_suites.push_back(suite);
endfunction


/*
  Method: report
  This task reports the results for the test suites
*/
function void svunit_testrunner::report();
  int     pass_cnt;
  string  success_str;

  if ($test$plusargs("SVUNIT_LIST_TESTS"))
    return;

  pass_cnt = get_num_passing_testsuites();

  if (pass_cnt == list_of_suites.size()) begin
    success_str = "PASSED";
    success = PASS;
  end else begin
    success_str = "FAILED";
    success = FAIL;
  end

  `LF;
  `INFO($sformatf("%0s (%0d of %0d suites passing) [%s]",
    success_str,
    pass_cnt,
    list_of_suites.size(),
    svunit_version));

  write_xml();
endfunction
