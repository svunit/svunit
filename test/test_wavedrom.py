import subprocess
import sys

import pytest

from utils import *


@all_files_in_dir('wavedrom_0')
def test_wavedrom_0(datafiles):
    if not (sys.version_info[0] == 3 and sys.version_info[1] == 6):
        pytest.skip('Wavedrom code only seems to work for Python 3.6')
    with datafiles.as_cwd():
        subprocess.check_call(['python3', 'wavedrom-test.py'])


@all_files_in_dir('wavedrom_1')
@all_available_simulators()
def test_wavedrom_1(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator, '-w'])
        expect_testrunner_pass('run.log')
