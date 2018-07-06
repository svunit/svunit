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

from .svunit_comp_log_parser import svunit_comp_log_parser
import logging, re

class svunit_questa_comp_log_parser(svunit_comp_log_parser):
  """
  Class that processes questa compile logs to check for
  errors, failures and problems.
  
  A child class of svunit_comp_log_parser which contains
  the bulk of the functional code.
  
  This class overrides some methods that specialise the 
  comp_log_parser for use with the questa tool:
    * adds regular expressions that target the
      questa message formats
    * methods to process the matched regular expressions
      to set parent class variable to allow a consistent
      report generation if failures are found
  """
  #-------------------------------------------------------------------
  # _compile_regexs
  #---------------------------------------------------------
  def _compile_regexs(self):
    """
    Compiles the regular expressions that are used to parse the logfile
    """
    self.regex_items['ERROR_MSG'] = re.compile('^\*\*\s+Error:\s*(.+)')
    self.regex_items['FATAL_MSG'] = re.compile('^\*\*\s+Fatal:\s*(.+)')
    self.regex_items['COMPILE_RESULT'] = re.compile('^Errors:\s+(\d+),\s+Warnings:\s+(\d+)$')

    # Error string sub-string parsing
    self.regex_items['ERROR_IN_FILE_MSG'] = re.compile('.+\/(\w+\.\w+)\((\d+)\):\s*(.+)')
    self.regex_items['ERROR_FILE_NOT_FOUND_MSG'] = re.compile('Failed to open .+ file \"(\S+)\" in read mode.')
  #-------------------------------------------------------------------
  # __init__
  #---------------------------------------------------------
  def __init__(self, debug_level=logging.WARN):
    #python 3
    #super().__init__(self, debug_level)
    # python 2
    svunit_comp_log_parser.__init__(self, debug_level)

  #-------------------------------------------------------------------
  # _process_fatal_msg
  #---------------------------------------------------------
  def _process_fatal_msg(self, regex_search_result):
    """
    Method to process the matched regex for fatal messages
    The fatal is stored in the parents error_message variable
    and the method returns true to allow the parent to continue
    parsing the log file.  The compile result ends the parsing
    for questa logs.
    """
    
    
    self.error_message = "Build fatal message: %s" % (regex_search_result.group(1))
    return True

  #-------------------------------------------------------------------
  # _process_error_msg
  #---------------------------------------------------------
  def _process_error_msg(self, regex_search_result):
    """
    Method to process the matched regex for error messages
    The error is stored in the parents error_message variable
    and the method returns true to allow the parent to continue
    parsing the log file.  The compile result ends the parsing
    for questa logs.
    """
    self.error_message = "Build error message: %s" %(regex_search_result.group(1))
    #self.error_message = "Build error message %s in file %s line %s : %s" % (regex_search_result.group(1),regex_search_result.group(2),regex_search_result.group(3),regex_search_result.group(4))
    return True

  #-------------------------------------------------------------------
  # _process_compile_result
  #---------------------------------------------------------
  def _process_compile_result(self, regex_search_result):
    """
    Method to process the matched regex for compile result messages
    returns true if there were zero errors reported
    """
    self.failure_message = "Build failed: %s" % (regex_search_result.group(0))
    return (regex_search_result.group(1) == "0")
