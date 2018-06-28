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

from .context import svunit_comp_log_parser
import unittest, os

class test_svunit_comp_log_parser(unittest.TestCase):
  """
  Python unittest for the svunit_questa_comp_log_parser class
  """

  #-------------------------------------------------------------------
  # setUp
  #---------------------------------------------------------
  def setUp(self):
      self.test_item = svunit_comp_log_parser()

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
    Helper method to create a file with the provided name and
    contents.  Used for basic testing.
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
    Helper method to delete a file.
    Used to tidy up after the test has finished.
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
    Test the process_logfile method when the file does not exist
    """
    # Check the method returns false
    self.assertFalse(self.test_item.process_logfile(logfile="foo_logfile_not_present"))

    # Check the values of the dummy results that are created when
    # the file is not found
    # TODO

  #-------------------------------------------------------------------
  # test_valid_logfile
  #---------------------------------------------------------
  def test_valid_logfile(self):
    """
    Test the process_logfile method when the file does exist and
    contains text that show the comp file indicates a valid compilation
    """
    test_filename = "foo_file_1256326"
    test_file_contents = "Compile complete string"

    if (self.create_dummy_file(test_filename, test_file_contents)):
      self.assertTrue(self.test_item.process_logfile(logfile=test_filename))

    self.remove_dummy_file(test_filename)

  #-------------------------------------------------------------------
  # test_invalid_logfile
  #---------------------------------------------------------
  def test_invalid_logfile(self):
    """
    Test the process_logfile method when the file does exist and
    contains text that show the comp file indicates a valid compilation
    """
    test_filename = "foo_file_1256326"
    test_file_contents = "fake file content, that will trigger a failure"

    if (self.create_dummy_file(test_filename, test_file_contents)):
      self.assertFalse(self.test_item.process_logfile(logfile=test_filename))

    self.remove_dummy_file(test_filename)

if __name__ == '__main__':
  unittest.main()
