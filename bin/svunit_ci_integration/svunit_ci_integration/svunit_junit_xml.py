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

import logging, sys, argparse
from svunit_sim_log_parser.svunit_sim_log_parser import svunit_sim_log_parser
from svunit_sim_log_parser.svunit_questa_sim_log_parser import svunit_questa_sim_log_parser
from svunit_sim_log_parser.svunit_ius_sim_log_parser import svunit_ius_sim_log_parser
from svunit_comp_log_parser.svunit_comp_log_parser import svunit_comp_log_parser
from svunit_comp_log_parser.svunit_questa_comp_log_parser import svunit_questa_comp_log_parser
from svunit_comp_log_parser.svunit_ius_comp_log_parser import svunit_ius_comp_log_parser

#-------------------------------------------------------------------------------
# get_verbosity_level
#---------------------------------------------------------------------
def _get_verbosity_level(verbosity_str):
  """
  helper method to convert the verbosity string to the correct logging type
  """
  result = logging.ERROR
  if (verbosity_str == "DEBUG"):
    result = logging.DEBUG;
  elif (verbosity_str == "INFO"):
    result = logging.INFO
  elif (verbosity_str == "WARN"):
    result = logging.WARN
  return result

#-------------------------------------------------------------------------------
# get_verbosity_level
#---------------------------------------------------------------------
def process_svunit_logs(sim_logfile="run.log",
                        comp_logfile="compile.log",
                        junit_outfile="results.xml",
                        dut_name="",
                        simulator="QUESTA",
                        verbosity="WARN"):
  """
  Main method that can be called when used as a package item
  """
  #-------------------------------------------------------------------
  # set the verbosity level
  #---------------------------------------------------------
  verbosity_level = _get_verbosity_level(verbosity)

  #-------------------------------------------------------------------
  # parse the compile log
  #---------------------------------------------------------
  if (simulator == "QUESTA"):
    comp_parser = svunit_questa_comp_log_parser(verbosity_level)
    simlog_parser = svunit_questa_sim_log_parser(dut_name, verbosity_level)
  elif (simulator == "IRUN"):
    comp_logfile = sim_logfile
    comp_parser = svunit_ius_comp_log_parser(verbosity_level)
    simlog_parser = svunit_ius_sim_log_parser(dut_name, verbosity_level)
  elif (simulator == "VCS"):
    comp_parser = svunit_comp_log_parser(verbosity_level)
    simlog_parser = svunit_sim_log_parser(dut_name, verbosity_level)

  if (comp_parser.process_logfile(comp_logfile) == False):
    comp_parser.save_junit_xml(junit_outfile)

  #-------------------------------------------------------------------
  # parse the simulator log
  #---------------------------------------------------------
  else:
    simlog_parser.process_logfile(sim_logfile)
    simlog_parser.save_junit_xml(junit_outfile)

#-------------------------------------------------------------------------------
# Main : parse the sim log
#---------------------------------------------------------------------
if __name__ == "__main__":
  # execute only if run as a script

  #-------------------------------------------------------------------
  # parse the commandline arguments
  #---------------------------------------------------------
  parser = argparse.ArgumentParser()
  parser.add_argument('--sim_logfile',
                      default="run.log",
                      help='SVUnit simulator log file name')
  parser.add_argument('--comp_logfile',
                      default="compile.log",
                      help='SVUnit compile log file name')
  parser.add_argument('--junit_outfile',
                      default="results.xml",
                      help='JUnit XML output file name')
  parser.add_argument('--dut_name',
                      default="",
                      help='DUT name used in error messages')
  parser.add_argument('--simulator', '-s',
                      default="QUESTA",
                      choices=['QUESTA','IRUN','VCS'],
                      help='Simulator used to generate the logs')
  parser.add_argument('--verbosity',
                      default="ERROR",
                      choices=['DEBUG','INFO','WARN','ERROR'],
                      help='Log verbosity')

  args = parser.parse_args()

  #-------------------------------------------------------------------
  # process the logs
  #---------------------------------------------------------
  process_svunit_logs(sim_logfile=args.sim_logfile,
                      comp_logfile=args.comp_logfile,
                      junit_outfile=args.junit_outfile,
                      dut_name=args.dut_name,
                      simulator=args.simulator,
                      verbosity=args.verbosity)
