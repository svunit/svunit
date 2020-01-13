import subprocess
from utils import *


@all_files_in_dir('wavedrom_0')
def test_wavedrom_0(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['python3', 'wavedrom-test.py'])


@all_files_in_dir('wavedrom_1')
@all_available_simulators()
def test_wavedrom_1(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator, '-w'])
        expect_testrunner_pass('run.log')
