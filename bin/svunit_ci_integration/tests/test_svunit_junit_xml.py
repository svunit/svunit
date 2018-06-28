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

from .context import svunit_junit_xml
import unittest

class test_svunit_testsuite(unittest.TestCase):
  """
  Python unittest for the svunit_questa_comp_log_parser class
  """

  #-------------------------------------------------------------------
  # setUp
  #---------------------------------------------------------
  def setUp(self):
    pass

  #-------------------------------------------------------------------
  # test_create_testname
  #---------------------------------------------------------
  def test_check_call_to_method(self):
    """
    Sanity test to show that the main function of the svunit_junit_xml package
    can be called
    """
    svunit_junit_xml.process_svunit_logs()
