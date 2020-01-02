import fileinput
import subprocess
import pathlib
import pytest
from test_utils import *


def all_files_in_dir(dirname):
    dirpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), dirname)
    return pytest.mark.datafiles(
            *pathlib.Path(dirpath).iterdir(),
            keep_top_dir=True,
            )


@all_files_in_dir('sim_0')
def test_sim_0(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s])
            expect_testrunner_pass('run.log')


@all_files_in_dir('sim_1')
def test_sim_1(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s])
            expect_testrunner_pass('run.log')
