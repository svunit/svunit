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

import logging, sys, argparse, os

#-------------------------------------------------------------------------------
# Class : svunit_gen_jenkinsfile
#---------------------------------------------------------------------
class svunit_gen_jenkinsfile():
  """
  """

  #-------------------------------------------------------------------
  # string constants
  #---------------------------------------------------------
  def _exec_dir_token(self):
    return '<<EXEC_DIR>>'
  def _runsvnunit_cmd_token(self):
    return '<<RUNSVUNIT_CMD>>'
  def _junit_resultfile_token(self):
    return '<<JUNIT_RESULT_FILE>>'

  #-------------------------------------------------------------------
  # _create_script_str
  #---------------------------------------------------------
  def _create_script_str(self):
    """
    """
    self.script_string = """
properties([parameters([string(defaultValue: '%s', description: 'path to SVUnit exec directory from repo root', name: 'SVUNIT_EXEC_DIR', trim: false)])])
node {
    stage('Checkout') {
        checkout scm
    }
    stage('Build') {
        if (isUnix()) {
            sh '''
                cd \$SVUNIT_EXEC_DIR;
                %s
               '''
        }
    }
    stage('Results') {
        junit '%s'
    }
}     
    """ % (self._exec_dir_token(), self._runsvnunit_cmd_token(), self._junit_resultfile_token())

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
  def __init__(self,
               _outfilename="Jenkinsfile",
               _cmdline="<<replace with runSVUnit command>>",
               _junit_results_file="results.xml",
               _debug_level=logging.WARN):
    """
    """
    self.outfilename = _outfilename
    self.exec_dir = '<<replace relative path from SCM root>>'
    self.runsvunit_cmd = _cmdline
    self.junit_resultfile_path = '\$SVUNIT_EXEC_DIR/'
    self.junit_resultfile = _junit_results_file

    self._setup_logger(_debug_level)
    self._create_script_str()


  #-------------------------------------------------------------------
  # _which
  #---------------------------------------------------------
  def _which(self, program):
    def is_exe(fpath):
        return os.path.exists(fpath) and os.access(fpath, os.X_OK) and os.path.isfile(fpath)

    def ext_candidates(fpath):
        yield fpath
        for ext in os.environ.get("PATHEXT", "").split(os.pathsep):
            yield fpath + ext

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            for candidate in ext_candidates(exe_file):
                if is_exe(candidate):
                    return candidate

    return None

  #-------------------------------------------------------------------
  # _check_if_git_repo
  #---------------------------------------------------------
  def _check_if_git_repo(self):
    if (self._which('git')):
      self.logger.debug("git command exists")
    return False

  #-------------------------------------------------------------------
  # _check_if_svn_repo
  #---------------------------------------------------------
  def _check_if_svn_repo(self):
    if (self._which('svn')):
      self.logger.debug("svn command exists")
      if (os.path.isdir('.svn')):
        return True
    return False

  #-------------------------------------------------------------------
  # _discover_exec_path
  #---------------------------------------------------------
  def _discover_exec_path(self):
    """
    """
    if (self._check_if_git_repo()):
      self.logger.debug("SCM is git, building path")
      # TODO: get the git root dir and current path, then override 
      #    'git rev-parse --show-toplevel'
      #
    elif (self._check_if_svn_repo()):
      self.logger.debug("SCM is svn, building path")
      # TODO: get the svn root dir and current path, then override       
      #    os.path.isdir()
      #    os.path.isfile()
    else:
      self.logger.debug("unrecognised SCM, saving absolute path to allow user to truncate")
      self.exec_dir = os.getcwd()


  #-------------------------------------------------------------------
  # _replace_token
  #---------------------------------------------------------
  def _replace_token(self, token, new_substr):
    self.script_string = self.script_string.replace(token, new_substr)

  #-------------------------------------------------------------------
  # resolve_tokens
  #---------------------------------------------------------
  def resolve_tokens(self):
    """
    """
    self._discover_exec_path()

    self._replace_token(self._exec_dir_token(), self.exec_dir)
    self._replace_token(self._runsvnunit_cmd_token(), self.runsvunit_cmd)
    self._replace_token(self._junit_resultfile_token(), self.junit_resultfile_path + self.junit_resultfile)

  #-------------------------------------------------------------------
  # save_jenkinsfile
  #---------------------------------------------------------
  def save_jenkinsfile(self):
    """
    opens the logfile, processes the contents to populates the junit_xml classes
    """
    outfilename = "Jenkinsfile"
    try:
      with open(outfilename, 'w') as fh:
        fh.write(self.script_string)

    except IOError as exception:
      error_msg = "Exception on opening the logfile '%s': %s" % (outfilename, exception)
      self.logger.error(error_msg)

#-------------------------------------------------------------------------------
# Main : create the jenkinsfile
#---------------------------------------------------------------------
def create_jenkinsfile(outfilename="Jenkinsfile",
                       cmdline="<<replace with runSVUnit command>>",
                       junit_results_file="results.xml",
                       verbosity="WARN"):

  gen_jenkinsfile = svunit_gen_jenkinsfile(outfilename,
                                           cmdline,
                                           junit_results_file,
                                           verbosity)
  gen_jenkinsfile.resolve_tokens()
  gen_jenkinsfile.save_jenkinsfile()

#-------------------------------------------------------------------------------
# Main : create the jenkinsfile
#---------------------------------------------------------------------
if __name__ == "__main__":
  # execute only if run as a script

  #-------------------------------------------------------------------
  # parse the commandline arguments
  #---------------------------------------------------------
  parser = argparse.ArgumentParser()
  parser.add_argument('--outfilename',
                      default="Jenkinsfile",
                      help='SVUnit Jenkins pipeline filename')
  parser.add_argument('--cmdline',
                      default="<<replace with runSVUnit command>>",
                      help='runSVUnit commandline')
  parser.add_argument('--junit_results_file',
                      default="results.xml",
                      help='JUnit XML file name and relative path')
  parser.add_argument('--verbosity',
                      default="ERROR",
                      choices=['DEBUG','INFO','WARN','ERROR'],
                      help='Log verbosity')

  args = parser.parse_args()

  #-------------------------------------------------------------------
  # process the logs
  #---------------------------------------------------------
  create_jenkinsfile(outfilename=args.outfilename,
                     cmdline=args.cmdline,
                     junit_results_file=args.junit_results_file,
                     verbosity=args.verbosity)
  
