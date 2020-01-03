import subprocess
from utils import *


@all_files_in_dir('wavedrom_0')
def test_wavedrom_0(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['python3', 'wavedrom-test.py'])


@all_files_in_dir('wavedrom_1')
def test_wavedrom_1(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s, '-w'])
            expect_testrunner_pass('run.log')
