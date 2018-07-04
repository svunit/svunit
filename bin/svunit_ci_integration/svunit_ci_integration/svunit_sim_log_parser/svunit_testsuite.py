################################################################
#
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
#
################################################################

from junit_xml import TestCase
import logging

#-------------------------------------------------------------------------------
# Class : svunit_testsuite
#---------------------------------------------------------------------
class svunit_testsuite:
  """
  Class container to hold the junit_xml testcases and other state
  
  This class has been created to allow the incremental construction
  of the dataset before it is used to generate the JUint class items.
  """
  passed_string = 'PASSED'
  failed_string = 'FAILED'

  def __init__(self):
    self.test_case_dict = {}
    self.passing_tests = 0
    self.total_tests = 0
    self.logger = logging.getLogger('sim_log_parser.testsuites')

  def create_testcase(self, testname):
    """
    Create a testcase within the test suite
    
    Parameter: testname - string - unique test name
    """
    self.test_case_dict[testname] = TestCase(testname)

  def add_testcase_error(self, testname, error_timestamp, error_msg):
    """
    Updates the error info of a test case
    
    Parameters:
      testname - string - unique test name that exists in the suite
      error_timestamp - int - simulation time of error
      error_msg - string - error message captured from the simulation log
    """
    # only add the first error
    if (testname in self.test_case_dict):
      if (self.test_case_dict[testname].is_error()):
        self.logger.debug("skipping error: error already captured")
      else:
        self.test_case_dict[testname].add_error_info(error_msg)
        self.test_case_dict[testname].timestamp = error_timestamp
    else:
      self.logger.debug("skipping error: testname not found")

  def finalize_testcase(self, testname, result):
    """
    Finalizes a test case. This sets flags in the testcase to appropriate
    values to ensure the test is shown as a pass or fail in the results.
    
    Parameters:
      testname - string - unique test name that exists in the suite
      result - string - "PASSED" or "FAILED"
    """
    if (testname in self.test_case_dict):
      self.test_case_dict[testname].status = result;
      self.total_tests += 1

      if (result != self.passed_string):
        self.test_case_dict[testname].add_failure_info(result)
      else:
        self.passing_tests += 1

  def check_results(self, suite_result, passing_count, total_count):
    """
    Checks the testsuite results are consistent with input parameters
    
    Parameters:
      suite_result - string -  "PASSED" or "FAILED"
      passing_count - int - expected number of passing tests in this suite
      total_count - int - expected number of total tests in this suite
    """
    dbg_msg = "exp_passing %d, act_passing %d. exp_total %d, act_total %d" % (passing_count, self.passing_tests, total_count, self.total_tests)
    self.logger.debug(dbg_msg)
    if (passing_count != self.passing_tests) or (total_count != self.total_tests):
      return False
    else:
      if (self.passing_tests != self.total_tests):
        if (suite_result != self.failed_string):
          return False
        else:
          return True
      else:
        if (suite_result != self.passed_string):
          return False
        else:
          return True

  def get_testcases(self):
    """
    Returns all test cases in a list.
    
    The JUnit testsuite class is created with a list of testcases.
    """
    return list(self.test_case_dict.values())
