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
from .svunit_sim_log_parser import svunit_sim_log_parser
import logging, re

#-------------------------------------------------------------------------------
# Class : svunit_ius_sim_log_parser
#---------------------------------------------------------------------
class svunit_ius_sim_log_parser(svunit_sim_log_parser):
  """
  Parses the SVUnit simulation log and generates the JUnit XML file

  Although each simulator has slightly different formats for messages,
  the SVUnit messages are standardised.  
  
  The exception to the standard messages is the fatal message
  that can come from the simulator.
  """
  #-------------------------------------------------------------------
  # _compile_regexs
  #---------------------------------------------------------
  def _compile_regexs(self):
    """
    Compiles the regular expressions that are used to parse the logfile
    """
    svunit_sim_log_parser._compile_regexs(self)
    self.regex_items['SIM_FATAL'] = re.compile('^\w+:\s+\*F,(.+)')

  #-------------------------------------------------------------------
  # __init__
  #---------------------------------------------------------
  def __init__(self, _dut_name, _debug_level=logging.WARN):
    svunit_sim_log_parser.__init__(self, _dut_name, _debug_level)

  #-------------------------------------------------------------------
  # _process_sim_fatal
  #---------------------------------------------------------
  def _process_sim_fatal(self, _regex_result):
    """
    Method to process the SIM_FATAL regex results
    """
    self.logger.debug("Simulation fatal message found.")
    fatal_msg = "Simulator fatal message seen: %s" % (_regex_result.group(1))
    self._add_testcase_error(fatal_msg)

    if (self.current_suite != ""):
      self._finalise_test_suite(_suite_name=self.current_suite,
                                _suite_result="FAILED", 
                                _passing_count=0, 
                                _total_count=0)
