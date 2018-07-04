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

import re, os, logging
from junit_xml import TestSuite, TestCase
from .svunit_testsuite import svunit_testsuite

#-------------------------------------------------------------------------------
# Class : svunit_sim_log_parser
#---------------------------------------------------------------------
class svunit_sim_log_parser:
  """
  Parses the SVUnit simulation log and generates the JUnit XML file

  Although each simulator has slightly different formats for messages,
  the SVUnit messages are standardised.  The slight variation between
  simulators can be dealt with in the regular expressions. If
  support for a new simulator is needed that cannot be supported with
  the implemented regular expressions, a child class can be created
  to override as required.
  """

  #-------------------------------------------------------------------
  # _compile_regexs
  #---------------------------------------------------------
  def _compile_regexs(self):
    """
    Compiles the regular expressions that are used to parse the logfile
    """
    self.regex_items['ERROR_MSG'] = re.compile('^.*ERROR:\s+\[(\d+)\]\[(\w+)\]:\s+(.+)')
    self.regex_items['SUITE_REGISTER'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]: Registering Unit Test Case (\w+)')
    self.regex_items['SUITES_REGISTER'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]: Registering Test Suite (\w+)')

    self.regex_items['SUITES_BEGIN'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]:\s+RUNNING')
    self.regex_items['SUITES_END'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]:\s+(\w+)\s+\((\d+)\s+of\s+(\d+)\s+testcases\s+passing\)')

    self.regex_items['SUITE_BEGIN'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]:\s+RUNNING')
    self.regex_items['SUITE_END'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]:\s+(\w+)\s+\((\d+)\s+of\s+(\d+)\s+tests\s+passing\)')

    self.regex_items['TEST_BEGIN'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]:\s+(\w+)::RUNNING')
    self.regex_items['TEST_END'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]:\s+(\w+)::(\w+)')

    self.regex_items['SVUNIT_END'] = re.compile('^.*INFO:\s+\[\d+\]\[(\w+)\]:\s+(\w+)\s+\((\d+)\s+of\s+(\d+)\s+suites\s+passing\).+')

  #-------------------------------------------------------------------
  # _setup_logger
  #---------------------------------------------------------
  def _setup_logger(self, debug_level):
    """
    Helper method to setup a logger that can be used to generate
    messages during execution

    This method is not expected to be overridden by the child class
    """
    self.logger = logging.getLogger("sim_log_parser")
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
  # __init__
  #---------------------------------------------------------
  def __init__(self, debug_level=logging.WARN):
    self.regex_items = {}
    self.regex_result = None
    self.test_suites = []
    self.testsuite_dict = {}
    self.current_suite = ""
    self.current_test = ""
    self.suites_name = ""
    self.suites_errors = 0


    self._setup_logger(debug_level)
    self._compile_regexs()

  #-------------------------------------------------------------------
  # _parse_line
  #---------------------------------------------------------
  def _parse_line(self, line, regex_target):
    """
    Checks the line against the requested regular expression
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
    Helper method to create a results class structure if a problem
    processing the simulation log occurs
    """

    fake_test_case = TestCase(name='post_run_processing') # log?

    if (failure_message == ""):
      failure_message = "Unknown failure, please check logs"
    fake_test_case.add_failure_info(failure_message)

    self.test_suites = [TestSuite("SVUnit_post_processing", [fake_test_case])]

  #-------------------------------------------------------------------
  # _create_svunit_testsuite
  #---------------------------------------------------------
  def _create_svunit_testsuite(self, _suite_name):
    self.testsuite_dict[_suite_name] = svunit_testsuite()
    self.logger.debug("Suite registered : %s" % (_suite_name))

  #-------------------------------------------------------------------
  # _process_suite_register
  #---------------------------------------------------------
  def _update_current_suite(self, _suite_name):
    """
    Method to update the current_suite or ignore if it matches
    the suites_name
    """
    if (_suite_name in self.testsuite_dict):
      self.logger.debug("Start of suite : %s" % (_suite_name))
      self.current_suite = _suite_name
    elif (_suite_name == self.suites_name):
      self.logger.debug("Start of suites : %s" % (_suite_name))
    else:
      self.logger.error("Unregistered test suite '%s' started", _suite_name)

  #-------------------------------------------------------------------
  # _finalise_test_suite
  #---------------------------------------------------------
  def _finalise_test_suite(self, _suite_name, _suite_result, _passing_count, _total_count):
    """
    Helper method to check the results reported by SVUnit match those captured in the testsuite
    """
    if (_suite_name in self.testsuite_dict):
      if (self.testsuite_dict[_suite_name].check_results(_suite_result, _passing_count, _total_count)):
        test_case_list = self.testsuite_dict[_suite_name].get_testcases()
        self.test_suites.append(TestSuite(_suite_name, test_case_list))

        # TODO: should we remove the items from the dictionary?
      else:
        self.logger.error("Test count results do not match for '%s'", _suite_name)
    else:
      self.logger.error("Unregistered test suite '%s' reported finshed", _suite_name)

    # clear current_suite
    self.current_suite = ""

  #-------------------------------------------------------------------
  # _create_testcase
  #---------------------------------------------------------
  def _create_testcase(self, _suite_name, _test_name):
    if (_suite_name in self.testsuite_dict):
      self.logger.debug("Start of test : %s::%s" % (_suite_name, _test_name))
      self.testsuite_dict[_suite_name].create_testcase(_test_name)
      self.current_test = _test_name
    else:
      self.logger.error("Unregistered test suite '%s' starting test %s", _suite_name, _test_name)

  #-------------------------------------------------------------------
  # _finalise_testcase
  #---------------------------------------------------------
  def _finalise_testcase(self, _suite_name, _test_name, _test_result):
    if (_test_result != "RUNNING"):
      if (_suite_name in self.testsuite_dict):
        self.testsuite_dict[_suite_name].finalize_testcase(_test_name, _test_result)
        self.logger.debug("End of test : %s::%s %s" % (_suite_name, _test_name, _test_result))

      else:
        self.logger.error("Unregistered test suite '%s' reported finshed test %s", _suite_name, _test_name)

      # clear the current test variable
      self.current_test = ""

  #-------------------------------------------------------------------
  # _add_testcase_error
  #---------------------------------------------------------
  def _add_testcase_error(self, _error_msg, _error_timestamp=0):
    """
    uses the current_suite and current_test variables to
    add error info to the testcase

    TODO
    """
    curr_test = self.current_test
    curr_suite = self.current_suite
    self.logger.debug("Error message - suite(%s) test(%s): %s" % (curr_test,
                                                                  curr_suite,
                                                                  _error_msg))

    if (curr_suite == ""):
      self.logger.debug("Error arrived outside an active suite. Using suites name")
      # Outside a suite, so we need to make a fake one
      curr_suite = self.suites_name

      if (curr_suite not in self.testsuite_dict):
        self._create_svunit_testsuite(curr_suite)

    if (curr_test == ""):
      # outside a test, so create a fake test
      curr_test = "%s_error_%d" % (curr_suite, self.suites_errors)
      self._create_testcase( _suite_name=curr_suite, _test_name=curr_test)
      self.suites_errors += 1


    if (curr_suite in self.testsuite_dict):
      self.testsuite_dict[curr_suite].add_testcase_error(testname=curr_test,
                                                         error_timestamp=_error_timestamp,
                                                         error_msg=_error_msg)
    

  #-------------------------------------------------------------------
  # _process_suites_register
  #---------------------------------------------------------
  def _process_suites_register(self, _regex_result):
    """
    Method to process the SUITES_REGISTER regex

    Must set the suites_name
    """
    self.suites_name = _regex_result.group(2)

  #-------------------------------------------------------------------
  # _process_suite_register
  #---------------------------------------------------------
  def _process_suite_register(self, _regex_result):
    """
    Method to process the SUITE_REGISTERr regex results

    Must create a new svnunit_testsuite by calling
      _create_svunit_testsuite
    """
    suite_name = _regex_result.group(2)
    self._create_svunit_testsuite(suite_name)

  #-------------------------------------------------------------------
  # _process_suite_begin
  #---------------------------------------------------------
  def _process_suite_begin(self, _regex_result):
    """
    Method to process the SUITE_BEGIN regex results

    Must set the current_suite variable by calling
      _update_current_suite
    """
    suite_name = self.regex_result.group(1)
    self._update_current_suite(suite_name)

  #-------------------------------------------------------------------
  # _process_suite_end
  #---------------------------------------------------------
  def _process_suite_end(self, _regex_result):
    """
    Method to process the SUITE_END regex results

    Must finalise the suite by calling
      _finalise_test_suite
    """
    suite_name = _regex_result.group(1)
    suite_result = _regex_result.group(2)
    passing_count = int(_regex_result.group(3))
    total_count = int(_regex_result.group(4))

    self._finalise_test_suite(suite_name, suite_result, passing_count, total_count)

  #-------------------------------------------------------------------
  # _process_test_begin
  #---------------------------------------------------------
  def _process_test_begin(self, _regex_result):
    """
    Method to process the TEST_BEGIN regex results

    Must create a test case calling
      _create_testcase
    """
    suite_name = _regex_result.group(1)
    test_name = _regex_result.group(2)

    self._create_testcase(suite_name, test_name)

  #-------------------------------------------------------------------
  # _process_test_end
  #---------------------------------------------------------
  def _process_test_end(self, _regex_result):
    """
    Method to process the TEST_END regex results

    Must finalize the test case calling
      _finalise_testcase
    """
    suite_name = _regex_result.group(1)
    test_name = _regex_result.group(2)
    test_result = _regex_result.group(3)

    self._finalise_testcase(suite_name, test_name, test_result)

  #-------------------------------------------------------------------
  # _process_error_msg
  #---------------------------------------------------------
  def _process_error_msg(self, _regex_result):
    """
    Method to process the ERROR_MSG regex results

    Must add the error message to the test case by calling
      _add_testcase_error
    """
    error_message = _regex_result.group(3)
    error_timestamp = _regex_result.group(1)
    self._add_testcase_error(_error_msg=error_message,
                             _error_timestamp=error_timestamp)

  #-------------------------------------------------------------------
  # _process_svunit_end
  #---------------------------------------------------------
  def _process_svunit_end(self, _regex_result):
    """
    Method to process the SVUNIT_END regex results

    Nothing to do at the moment. Can be extended
    """
    self.logger.debug("End of processing")

  #-------------------------------------------------------------------
  # process_logfile
  #---------------------------------------------------------
  def _parse_sim_logfile(self, fh):
    """
    The main functional code that steps through the logfile by line
    calling the regular expressions to search for the test messages
    that are then used to build the JUnit class structures

    Note that the SUITES_BEGIN and SUITES_END regexs are not use currently
    """

    for line in fh:

      if (self._parse_line(line, 'SUITES_REGISTER')):
        self._process_suites_register(self.regex_result)

      elif (self._parse_line(line, 'SUITE_REGISTER')):
        self._process_suite_register(self.regex_result)

      elif (self._parse_line(line, 'SUITE_BEGIN')):
        self._process_suite_begin(self.regex_result)

      elif (self._parse_line(line, 'SUITE_END')):
        self._process_suite_end(self.regex_result)

      elif (self._parse_line(line, 'TEST_BEGIN')):
        self._process_test_begin(self.regex_result)

      elif (self._parse_line(line, 'TEST_END')):
        self._process_test_end(self.regex_result)

      elif (self._parse_line(line, 'ERROR_MSG')):
        self._process_error_msg(self.regex_result)

      elif (self._parse_line(line, 'SVUNIT_END')):
        self._process_svunit_end(self.regex_result)
        break

  #-------------------------------------------------------------------
  # process_logfile
  #---------------------------------------------------------
  def process_logfile(self, logfile):
    """
    opens the logfile, processes the contents to populates the junit_xml classes
    """
    try:
      with open(logfile, 'rU') as fh:
        self._parse_sim_logfile(fh)

    except IOError as exception:
      error_msg = "Exception on opening the logfile '%s': %s" % (logfile, exception)
      self.logger.debug(error_msg)
      self._create_fake_results(error_msg)

  #-------------------------------------------------------------------
  # print_junit_xml
  #---------------------------------------------------------
  def print_junit_xml(self):
    """
    Helper method to print out the XML data structure to console
    """
    print(TestSuite.to_xml_string(self.test_suites))

  #-------------------------------------------------------------------
  # save_junit_xml
  #---------------------------------------------------------
  def save_junit_xml(self, outfile_name):
    """
    method used to trigger the writing of the XML data structure to file
    """
    with open(outfile_name, 'w') as fh:
      TestSuite.to_file(file_descriptor=fh, test_suites=self.test_suites)
