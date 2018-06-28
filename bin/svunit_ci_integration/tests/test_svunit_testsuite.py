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

from .context import svunit_testsuite
import unittest

class test_svunit_testsuite(unittest.TestCase):
  """
  Python unittest for the svunit_questa_comp_log_parser class
  """

  #-------------------------------------------------------------------
  # setUp
  #---------------------------------------------------------
  def setUp(self):
      self.test_item = svunit_testsuite()

  #-------------------------------------------------------------------
  # tearDown
  #---------------------------------------------------------
#  def tearDown(self):
#      self.test_item.dispose()

  #-------------------------------------------------------------------
  # check_init_state
  #---------------------------------------------------------
  def check_init_state(self):
    """
    Helper method to check the initial state of the target class
    """
    # check the testcase dictionary is empty first
    self.assertEqual(len(self.test_item.test_case_dict),
                     0,
                     'dictionary not empty to start')

  #-------------------------------------------------------------------
  # test_create_testcase
  #---------------------------------------------------------
  def test_create_testcase(self):
    """
    Test to check the create_testcase method
    """
    test_name = "foo_testname"

    self.check_init_state()

    # now add an item 
    self.test_item.create_testcase(testname=test_name)

    # check that item exists
    self.assertEqual(len(self.test_item.test_case_dict),
                     1,
                     'dictionary size not as expected')

    self.assertTrue((test_name in self.test_item.test_case_dict),
                     'added test not found in the dictionary')

    self.assertEqual(self.test_item.test_case_dict[test_name].name,
                     test_name,
                     'added test had the wrong name')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=0,
                                    total_count=0)

    self.assertTrue(check_result,
                    'check results on empty with valid inputs')

    check_result = self.test_item.check_results(
                                    suite_result="FAILED",
                                    passing_count=0,
                                    total_count=0)

    self.assertFalse(check_result,
                    'check results on empty with invalid result input')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=1,
                                    total_count=0)

    self.assertFalse(check_result,
                    'check results on empty with invalid passing input')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=0,
                                    total_count=1)

    self.assertFalse(check_result,
                    'check results on empty with invalid total input')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=1,
                                    total_count=1)

    self.assertFalse(check_result,
                    'check results on empty with unmatched consistent input')



  #-------------------------------------------------------------------
  # test_create_testname
  #---------------------------------------------------------
  def test_add_testcase_error(self):
    """
    Test to check the add_testcase method with an error
    """
    test_name = "foo_testname2"
    error_msg = "foo_error"
    result_str = "FAILED"

    self.check_init_state()

    # now add an item 
    self.test_item.create_testcase(testname=test_name)

    # check that item exists
    self.assertEqual(len(self.test_item.test_case_dict),
                     1,
                     'dictionary size not as expected')

    self.assertTrue((test_name in self.test_item.test_case_dict),
                     'added test not found in the dictionary')

    self.assertEqual(self.test_item.test_case_dict[test_name].name,
                     test_name,
                     'added test had the wrong name')

    self.test_item.add_testcase_error(testname=test_name, error_timestamp=0, error_msg=error_msg)

    self.assertEqual(self.test_item.test_case_dict[test_name].error_message,
                     error_msg,
                     'added test had the wrong name')

    self.test_item.finalize_testcase(testname=test_name, result=result_str)

    self.assertEqual(self.test_item.test_case_dict[test_name].status,
                     result_str,
                     'finalized suite had the wrong status')

    self.assertEqual(self.test_item.test_case_dict[test_name].failure_message,
                     result_str,
                     'finalized suite had the wrong failed message')

    check_result = self.test_item.check_results(
                                    suite_result="FAILED",
                                    passing_count=0,
                                    total_count=1)

    self.assertTrue(check_result,
                    'check results on empty with valid inputs')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=0,
                                    total_count=1)

    self.assertFalse(check_result,
                    'check results on empty with invalid result input')

    check_result = self.test_item.check_results(
                                    suite_result="FAILED",
                                    passing_count=1,
                                    total_count=1)

    self.assertFalse(check_result,
                    'check results on empty with invalid passing input')

    check_result = self.test_item.check_results(
                                    suite_result="FAILED",
                                    passing_count=0,
                                    total_count=2)

    self.assertFalse(check_result,
                    'check results on empty with invalid total input')

    check_result = self.test_item.check_results(
                                    suite_result="FAILED",
                                    passing_count=1,
                                    total_count=2)

    self.assertFalse(check_result,
                    'check results on empty with unmatched consistent input')


  #-------------------------------------------------------------------
  # test_create_testname
  #---------------------------------------------------------
  def test_add_testcase_passing(self):
    """
    Test to check the add_testcase method with a passing result
    """
    test_name = "foo_testname3"
    error_msg = "foo_error4"
    result_str = "PASSED"

    self.check_init_state()

    # now add an item 
    self.test_item.create_testcase(testname=test_name)

    # check that item exists
    self.assertEqual(len(self.test_item.test_case_dict),
                     1,
                     'dictionary size not as expected')

    self.assertTrue((test_name in self.test_item.test_case_dict),
                     'added test not found in the dictionary')

    self.assertEqual(self.test_item.test_case_dict[test_name].name,
                     test_name,
                     'added test had the wrong name')

    self.test_item.finalize_testcase(testname=test_name, result=result_str)

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=1,
                                    total_count=1)

    self.assertTrue(check_result,
                    'check results with valid inputs')

    check_result = self.test_item.check_results(
                                    suite_result="FAILED",
                                    passing_count=1,
                                    total_count=1)

    self.assertFalse(check_result,
                    'check results with invalid result input')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=0,
                                    total_count=1)

    self.assertFalse(check_result,
                    'check results with invalid passing input')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=1,
                                    total_count=2)

    self.assertFalse(check_result,
                    'check results with invalid total input')

    check_result = self.test_item.check_results(
                                    suite_result="PASSED",
                                    passing_count=5,
                                    total_count=1)

    self.assertFalse(check_result,
                    'check results with unmatched consistent input')


if __name__ == '__main__':
  unittest.main()
