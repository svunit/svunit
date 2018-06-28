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

from .context import svunit_sim_log_parser
import unittest

class test_svunit_sim_log_parser(unittest.TestCase):
  """
  Python unittest class for the svunit_sim_log_parser class
  """
  #-------------------------------------------------------------------
  # setUp
  #---------------------------------------------------------
  def setUp(self):
      self.test_item = svunit_sim_log_parser()

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
    Helper function that checks the initial state of the class
    """

    self.assertTrue((self.test_item.regex_result == None),
                     'regex_result is not None')

    self.assertEqual(len(self.test_item.test_suites),
                     0,
                     'test_suites list size not as expected')

    self.assertEqual(len(self.test_item.regex_items),
                     10,
                     'regex dictionary size not as expected')

    self.assertTrue(('ERROR_MSG' in self.test_item.regex_items),
                     'ERROR_MSG test not found in the regex dictionary')

    self.assertTrue(('SUITE_REGISTER' in self.test_item.regex_items),
                     'SUITE_REGISTER test not found in the regex dictionary')

    self.assertTrue(('SUITES_REGISTER' in self.test_item.regex_items),
                     'SUITES_REGISTER test not found in the regex dictionary')

    self.assertTrue(('SUITES_BEGIN' in self.test_item.regex_items),
                     'SUITES_BEGIN test not found in the regex dictionary')

    self.assertTrue(('SUITES_END' in self.test_item.regex_items),
                     'SUITES_END test not found in the regex dictionary')

    self.assertTrue(('SUITE_BEGIN' in self.test_item.regex_items),
                     'SUITE_BEGIN test not found in the regex dictionary')

    self.assertTrue(('SUITE_END' in self.test_item.regex_items),
                     'SUITE_END test not found in the regex dictionary')

    self.assertTrue(('TEST_BEGIN' in self.test_item.regex_items),
                     'TEST_BEGIN test not found in the regex dictionary')

    self.assertTrue(('TEST_END' in self.test_item.regex_items),
                     'TEST_END test not found in the regex dictionary')

    self.assertTrue(('SVUNIT_END' in self.test_item.regex_items),
                     'SVUNIT_END test not found in the regex dictionary')


  #-------------------------------------------------------------------
  # test_check_init
  #---------------------------------------------------------
  def test_check_init(self):
    """
    Test to check the initial state of the target class
    """
    self.check_init_state()

  #-------------------------------------------------------------------
  # test_error_msg_regex
  #---------------------------------------------------------
  def test_error_msg_regex(self):
    """
    Test to check the error message regular expression
    """
    regex_tgt = "ERROR_MSG"

    #-------------------------------------------------------
    line_str = "foobar"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "ERROR: [0][dut_ut]: fail_if: fail (at /home2/rhotchkiss/work/svunit/svunit-code-master/test/sim_10/./dut_unit_test.sv line:49)"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 1 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "fail_if: fail (at /home2/rhotchkiss/work/svunit/svunit-code-master/test/sim_10/./dut_unit_test.sv line:49)",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# ERROR: [0][dut_ut]: fail_if: fail (at /home2/rhotchkiss/work/svunit/svunit-code-master/test/sim_10/./dut_unit_test.sv line:49)"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "fail_if: fail (at /home2/rhotchkiss/work/svunit/svunit-code-master/test/sim_10/./dut_unit_test.sv line:49)",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_suite_register_regex
  #---------------------------------------------------------
  def test_suite_register_regex(self):
    """
    Test to check the suite_register regular expression
    """
    regex_tgt = "SUITE_REGISTER"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][__ts]: Registering Unit Test Case dut_ut"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "__ts",
                     'regex group 1 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "dut_ut",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "#    INFO:  [0][__ts]: Registering Unit Test Case foobar_dut_ut"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "__ts",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "foobar_dut_ut",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_suites_register_regex
  #---------------------------------------------------------
  def test_suites_register_regex(self):
    """
    Test to check the suites_register regular expression
    """
    regex_tgt = "SUITES_REGISTER"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][testrunner]: Registering Test Suite __ts"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "testrunner",
                     'regex group 1 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "__ts",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# INFO:  [0][testrunner]: Registering Test Suite __ts"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "testrunner",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "__ts",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_suites_begin_regex
  #---------------------------------------------------------
  def test_suites_begin_regex(self):
    regex_tgt = "SUITES_BEGIN"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][__ts]: RUNNING"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "__ts",
                     'regex group 1 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     1,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# INFO:  [0][__ts]: RUNNING"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "__ts",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     1,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_suites_end_regex
  #---------------------------------------------------------
  def test_suites_end_regex(self):
    """
    Test to check the suites_end regular expression
    """
    regex_tgt = "SUITES_END"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][__ts]: PASSED (9 of 9 testcases passing)"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "__ts",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "PASSED",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(result.group(3),
                     "9",
                     'regex group 3 for IUS match was not as expected')
    self.assertEqual(result.group(4),
                     "9",
                     'regex group 4 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     4,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# INFO:  [1250][__dsgts]: FAILED (12 of 125 testcases passing)"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "__dsgts",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "FAILED",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(result.group(3),
                     "12",
                     'regex group 3 for Questa match was not as expected')
    self.assertEqual(result.group(4),
                     "125",
                     'regex group 4 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     4,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_suite_begin_regex
  #---------------------------------------------------------
  def test_suite_begin_regex(self):
    """
    Test to check the suite_begin regular expression
    """
    regex_tgt = "SUITE_BEGIN"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][dut_ut]: RUNNING"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 1 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     1,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "#    INFO:  [0][dut_ut]: RUNNING"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     1,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_suite_end_regex
  #---------------------------------------------------------
  def test_suite_end_regex(self):
    """
    Test to check the SUITE_END regular expression
    """
    regex_tgt = "SUITE_END"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][dut_ut]: FAILED (1 of 267 tests passing)"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "FAILED",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(result.group(3),
                     "1",
                     'regex group 3 for IUS match was not as expected')
    self.assertEqual(result.group(4),
                     "267",
                     'regex group 4 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     4,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# INFO:  [1250][__dsgts]: PASSED (125 of 125 tests passing)"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "__dsgts",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "PASSED",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(result.group(3),
                     "125",
                     'regex group 3 for Questa match was not as expected')
    self.assertEqual(result.group(4),
                     "125",
                     'regex group 4 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     4,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_test_begin_regex
  #---------------------------------------------------------
  def test_test_begin_regex(self):
    """
    Test to check the TEST_BEGIN regular expression
    """
    regex_tgt = "TEST_BEGIN"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][dut_ut]: fail_unless::RUNNING"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 1 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "fail_unless",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# INFO:  [0][dut_gesyh136_ut]: strictly_so_the_teardown_is_called125::RUNNING"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "dut_gesyh136_ut",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "strictly_so_the_teardown_is_called125",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     2,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_test_end_regex
  #---------------------------------------------------------
  def test_test_end_regex(self):
    """
    Test to check the TEST_END regular expression
    """
    regex_tgt = "TEST_END"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][dut_ut]: fail_unless::FAILED"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 1 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "fail_unless",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(result.group(3),
                     "FAILED",
                     'regex group 3 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     3,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# INFO:  [0][dut_ut]: fail_if_equal::PASSED"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "dut_ut",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "fail_if_equal",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(result.group(3),
                     "PASSED",
                     'regex group 3 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     3,
                     'regex group size for Questa match was not as expected')

  #-------------------------------------------------------------------
  # test_svunit_end_regex
  #---------------------------------------------------------
  def test_svunit_end_regex(self):
    """
    Test to check the SVUNIT_END regular expression
    """
    regex_tgt = "SVUNIT_END"

    #-------------------------------------------------------
    line_str = "fake line that shouldn't match the item"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result == None),
                     'result for mismatch was not None')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for mismatch')

    #-------------------------------------------------------
    line_str = "INFO:  [0][testrunner]: FAILED (0 of 1 suites passing) [SVUnit v3.30]"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for IUS match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for IUS match')
    self.assertEqual(result.group(1),
                     "testrunner",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(result.group(2),
                     "FAILED",
                     'regex group 2 for IUS match was not as expected')
    self.assertEqual(result.group(3),
                     "0",
                     'regex group 3 for IUS match was not as expected')
    self.assertEqual(result.group(4),
                     "1",
                     'regex group 4 for IUS match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     4,
                     'regex group size for IUS match was not as expected')

    #-------------------------------------------------------
    line_str = "# INFO:  [0][testrunner]: PASSED (12516 of 2567472 suites passing) [SVUnit v3.30]"
    result = self.test_item._parse_line(line=line_str, regex_target=regex_tgt)
    self.assertTrue((result != None),
                     'result for Questa match was not as expected')
    self.assertTrue((result == self.test_item.regex_result),
                     'result does not match regex_result for Questa match')
    self.assertEqual(result.group(1),
                     "testrunner",
                     'regex group 1 for Questa match was not as expected')
    self.assertEqual(result.group(2),
                     "PASSED",
                     'regex group 2 for Questa match was not as expected')
    self.assertEqual(result.group(3),
                     "12516",
                     'regex group 3 for Questa match was not as expected')
    self.assertEqual(result.group(4),
                     "2567472",
                     'regex group 4 for Questa match was not as expected')
    self.assertEqual(self.test_item.regex_items[regex_tgt].groups,
                     4,
                     'regex group size for Questa match was not as expected')

if __name__ == '__main__':
  unittest.main()
