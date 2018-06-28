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

from junit_xml import TestCase, TestSuite
import logging, re

class svunit_comp_log_parser:
  """
  Generic base class for parsing simulator compile logs.
  As each simulator has different formatting, each simulator
  needs specialisation. However, each simulator will contain
  the same kind of information and the result of the parsing
  should be the same.
  This class captures the common behaviours needed to
  parse the logfile, while offering methods that can be overridden
  by child classes to implement the specialisation.
  """

  #-------------------------------------------------------------------
  # _setup_logger
  #---------------------------------------------------------
  def _setup_logger(self, debug_level):
    """
    Helper method to setup a logger that can be used to generate
    messages during execution
    
    This method is not expected to be overridden by the child class
    """
    self.logger = logging.getLogger("comp_log_parser")
    self.logger.setLevel(debug_level)

    # create console handler with a higher log level
    ch = logging.StreamHandler()
    ch.setLevel(debug_level)

    # create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    ch.setFormatter(formatter)

    # add the handlers to the logger
    self.logger.addHandler(ch)

  #-------------------------------------------------------------------
  # _compile_regexs
  #---------------------------------------------------------
  def _compile_regexs(self):
    """
    Compiles the regular expressions that are used to parse the logfile
    
    These regular expressions are here as place holders and do not
    match to any given simulator.
    
    This method must be overridden in the child class to allow capture
    of the compile log messages that are of interest to the script
    """
    self.regex_items['FATAL_MSG'] = re.compile('^Fatal message string$')
    self.regex_items['ERROR_MSG'] = re.compile('^Error message string$')
    self.regex_items['COMPILE_RESULT'] = re.compile('^Compile complete string$')

  #-------------------------------------------------------------------
  # __init__
  #---------------------------------------------------------
  def __init__(self, debug_level=logging.WARN):
    self._setup_logger(debug_level)

    self.regex_items = {}
    self.regex_result = None
    self.fake_test_suite_result = None
    self.error_message = ""
    self.failure_message = ""

    self._compile_regexs()

  #-------------------------------------------------------------------
  # _parse_line
  #---------------------------------------------------------
  def _parse_line(self, line, regex_target):
    """
    Checks the line against the requested regular expression.
    
    This method is not expected to be overridden by the child class
    """
    if (regex_target in self.regex_items):
      self.regex_result = self.regex_items[regex_target].search(line)
    else:
      self.logger.error("Undefined regex target '%s'", regex_target)
      self.regex_result = None

    return self.regex_result

  #-------------------------------------------------------------------
  # create_fake_results
  #---------------------------------------------------------
  def _create_fake_results(self, failure_message=""):
    """
    The method creates a test suite structure that can be
    used to generate an XML result file reporting a build
    falure
    
    The test suite structure will contain the error and failure
    messages.  If neither of these class variables have been
    set during processing, the method will use some default
    messages indicating a problem
    
    This method is not expected to be overridden by the child class
    """
    if (self.failure_message == ""):
      self.failure_message = failure_message

    fake_test_case = TestCase(name='pre_run_build') # log?

    if (self.error_message == ""):
      fake_test_case.error_message = "Unknown error, please check logs"
    fake_test_case.add_error_info(self.error_message)

    if (self.failure_message == ""):
      self.failure_message = "Unknown failure, please check logs"
    fake_test_case.add_failure_info(self.failure_message)

    self.fake_test_suite_result = TestSuite("SVUnit_build", [fake_test_case])

  #-------------------------------------------------------------------
  # _process_fatal_msg
  #---------------------------------------------------------
  def _process_fatal_msg(self, regex_search_result):
    """
    This method is called when the regex for the FATAL_MSG
    matches with the logfile line being processed.
    
    This method must be overridden in the extended class
    to allow it to generate a suitable error_message with the
    data obtained by the regex.
    
    The method returns True or False to indicate if parsing
    should be terminated. This allows the _parse_comp_logfile
    method to truncate processing if required.
    """
    self.error_message = "Fatal in compile"
    return True

  #-------------------------------------------------------------------
  # _process_error_msg
  #---------------------------------------------------------
  def _process_error_msg(self, regex_search_result):
    """
    This method is called when the regex for the ERROR_MSG
    matches with the logfile line being processed.
    
    This method must be overridden in the extended class
    to allow it to generate a suitable error_message with the
    data obtained by the regex.
    
    The method returns True or False to indicate if parsing
    should be terminated. This allows the _parse_comp_logfile
    method to truncate processing if required.
    """
    self.error_message = "Error in compile"
    return True

  #-------------------------------------------------------------------
  # _process_compile_result
  #---------------------------------------------------------
  def _process_compile_result(self, regex_search_result):
    """
    This method is called when the regex for the COMPILE_RESULT
    matches with the logfile line being processed.
    
    This method must be overridden in the extended class
    to allow it to process the COMPILE_RESULT regex and modify
    state if required.
    
    The method should return True if the compile results shows
    the build succeeded, or False if it did not.
    """
    self.failure_message = "Build failed"
    return True

  #-------------------------------------------------------------------
  # _parse_comp_logfile
  #---------------------------------------------------------
  def _parse_comp_logfile(self, filehandle):
    """
    Steps through the compile logfile line by line looking for
    error, fatal, and end of build messages
    
    Initial implementation assumes regex covers all forms of
    the messages.  This may not be feasible, so the code
    may need to be revised to support more complex searching
    
    This method is not expected to be overridden by the child class
    """
    found_compile_result = False
    no_errors_found = True
    for line_num, line in enumerate(filehandle):
      if (self._parse_line(line, 'ERROR_MSG')):
        if (no_errors_found == True):
          self.logger.debug("Found an error message")
          continue_parse = self._process_error_msg(self.regex_result)
          no_errors_found = False
          if (continue_parse == False):
            break

      elif (self._parse_line(line, 'FATAL_MSG')):
        if (no_errors_found == True):
          self.logger.debug("Found a fatal message")
          continue_parse = self._process_fatal_msg(self.regex_result)
          no_errors_found = False
          if (continue_parse == False):
            break

      elif (self._parse_line(line, 'COMPILE_RESULT')):
        self.logger.debug("Found the compile result")
        found_compile_result = True
        no_errors_found &= self._process_compile_result(self.regex_result)
        break

    if (found_compile_result and no_errors_found):
      self.logger.debug("Returning true, compile result found without errors")
      return True
    else:
      self.logger.debug("Returning false, compile result found with errors")
      self._create_fake_results()
      return False

  #-------------------------------------------------------------------
  # process_logfile
  #---------------------------------------------------------
  def process_logfile(self, logfile):
    """
    Tries to open the compile log file. If the file is opened
    the contents are parsed.  If the open fails, a fake result structure
    is created that reports the OS exception
    
    This method is not expected to be overridden by the child class
    """
    try:
      with open(logfile, "r") as fh:
        parse_result = self._parse_comp_logfile(fh)
        return parse_result
    except IOError as exception_msg:
      self.logger.info("No compile file found. Generating XML results for build failure")
      self._create_fake_results("Check build process: %s" % (exception_msg))
      return False

  #-------------------------------------------------------------------
  # print_junit_xml
  #---------------------------------------------------------
  def print_junit_xml(self):
    """
    Prints the XML structure out to console if a structure exists
    otherwise a logger error is issued
    
    This method is not expected to be overridden by the child class
    """
    if (self.fake_test_suite_result != None):
      print(TestSuite.to_xml_string([self.fake_test_suite_result]))
    else:
      self.logger.error("No results from which to generate the XML. Check logs")

  #-------------------------------------------------------------------
  # save_junit_xml
  #---------------------------------------------------------
  def save_junit_xml(self, outfile_name):
    """
    Saves the XML structure out to file with the name supplied by the outfile_name
    parameter if a structure exists otherwise a logger error is issued
    
    This method is not expected to be overridden by the child class
    """
    if (self.fake_test_suite_result != None):
      with open(outfile_name, 'w') as fh:
        TestSuite.to_file(file_descriptor=fh, test_suites=[self.fake_test_suite_result])
    else:
      self.logger.error("No results from which to generate the XML. Check logs")
