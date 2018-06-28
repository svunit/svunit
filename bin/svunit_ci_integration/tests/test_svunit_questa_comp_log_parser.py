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

from .context import svunit_questa_comp_log_parser
import unittest, os, logging

class test_svunit_questa_comp_log_parser(unittest.TestCase):
  """
  Python unittest for the svunit_questa_comp_log_parser class
  """
  #-------------------------------------------------------------------
  # setUp
  #---------------------------------------------------------
  def setUp(self):
      self.test_item = svunit_questa_comp_log_parser(logging.ERROR)

  #-------------------------------------------------------------------
  # check_init_state
  #---------------------------------------------------------
  def check_init_state(self):
    pass

  #-------------------------------------------------------------------
  # test_check_init
  #---------------------------------------------------------
  def test_check_init(self):
    self.check_init_state()

  #-------------------------------------------------------------------
  # test_check_init
  #---------------------------------------------------------
  def create_dummy_file(self, filename, file_contents):
    """
    """
    try:
      with open(filename, "w") as fh:
        fh.write(file_contents)
        return True
    except IOError:
      self.assertTrue(False, "Test failed to created a dummy file")
      return False

  #-------------------------------------------------------------------
  # remove_dummy_file
  #---------------------------------------------------------
  def remove_dummy_file(self, filename):
    """
    """
    try:
      os.remove(filename)
    except OSError:
      pass

  #-------------------------------------------------------------------
  # test_no_logfile
  #---------------------------------------------------------
  def test_no_logfile(self):
    """
    Test to check behaviour when the logfile does not exist
    """
    self.assertFalse(self.test_item.process_logfile(logfile="foo_logfile_not_present"))

  #-------------------------------------------------------------------
  # test_error_msg_regex
  #---------------------------------------------------------
  def test_error_msg_regex(self):
    """
    Test to check the error message regex
    """
    test_regex_tgt = "ERROR_MSG"
    test_line='** Error: (vlog-13069) /project/mpp/rhotchkiss/mpp/sources/dv/uvc/axi4/unittest/./axi4_monitor_unit_test.sv(8): near "typedef": syntax error, unexpected "SystemVerilog keyword \'typedef\'"'

    regex_result = self.test_item._parse_line(line=test_line, regex_target=test_regex_tgt)
    self.assertTrue(regex_result != None,
                    test_regex_tgt + " regex did not match as expected")
    self.assertTrue(regex_result == self.test_item.regex_result)
    self.assertEqual(self.test_item.regex_items[test_regex_tgt].groups,
                     4)
    self.assertEqual(regex_result.group(1),
                     "vlog-13069")
    self.assertEqual(regex_result.group(2),
                     "axi4_monitor_unit_test.sv")
    self.assertEqual(regex_result.group(3),
                     "8")
    self.assertEqual(regex_result.group(4),
                     'near "typedef": syntax error, unexpected "SystemVerilog keyword \'typedef\'"')

  #-------------------------------------------------------------------
  # test_valid_logfile
  #---------------------------------------------------------
  def test_valid_logfile(self):
    """
    Test to check a valid logfile
    """
    test_filename = "foo_file_1256326"
    test_file_contents = "Errors: 0, Warnings: 4"

    if (self.create_dummy_file(test_filename, test_file_contents)):
      self.assertTrue(self.test_item.process_logfile(logfile=test_filename))

    self.remove_dummy_file(test_filename)

  #-------------------------------------------------------------------
  # test_invalid_logfile
  #---------------------------------------------------------
  def test_invalid_logfile(self):
    """
    Test to check an invalid logfile
    """
    test_filename = "foo_file_1sdg256326"
    test_file_contents = "Errors: 10, Warnings: 4"

    if (self.create_dummy_file(test_filename, test_file_contents)):
      self.assertFalse(self.test_item.process_logfile(logfile=test_filename))

    self.assertEqual(self.test_item.error_message,
                     "")

    self.assertEqual(self.test_item.failure_message,
                     "Build failed: " + test_file_contents)

    self.remove_dummy_file(test_filename)

if __name__ == '__main__':
  unittest.main()
