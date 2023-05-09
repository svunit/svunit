import subprocess
import sys

import pytest

from utils import *


@pytest.mark.skip(reason="Wavedrom code seems to be very flaky")
@all_files_in_dir('wavedrom_0')
def test_wavedrom_0(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['python3', 'wavedrom-test.py'])


@all_files_in_dir('wavedrom_1')
@all_available_simulators()
def test_wavedrom_1(datafiles, simulator):
    if simulator == 'verilator':
        pytest.skip(f"'Generated code has mismatching lengths and other lint warnings")
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator, '-w'])
        expect_testrunner_pass('run.log')
