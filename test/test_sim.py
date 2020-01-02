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


@all_files_in_dir('sim_2')
def test_sim_2(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s])
            expect_testrunner_pass('run.log')


@all_files_in_dir('sim_3')
def test_sim_3(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s])

            expect_string(br'INFO:  \[0\]\[dut_ut\]: RUNNING', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: first_test::RUNNING', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: first_test::PASSED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: second_test::RUNNING', 'run.log')
            expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_if: 1 (at .*dut_unit_test.sv line:66)', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: second_test::FAILED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: third_test::RUNNING', 'run.log')
            expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_unless: beam == 1 (at .*dut_unit_test.sv line:73)', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: third_test::FAILED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: fourth_test::RUNNING', 'run.log')
            expect_string(br"ERROR: \[0\]\[dut_ut\]: fail_if_equal: ('hf) === (15) (at .*dut_unit_test.sv line:80)", 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: fourth_test::FAILED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: fifth_test::RUNNING', 'run.log')
            expect_string(br"ERROR: \[0\]\[dut_ut\]: fail_unless_equal: (15) !== ('ha) (at .*dut_unit_test.sv line:86)", 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: fifth_test::FAILED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: FAILED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: sixth_test::RUNNING', 'run.log')
            expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_unless: bozo == 1 \[ bozo is wrong \] (at .*dut_unit_test.sv line:93)', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: sixth_test::FAILED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: seventh_test::RUNNING', 'run.log')
            expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_if: bozo != 2 \[ gum is wrong 4 \] (at .*dut_unit_test.sv line:99)', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: seventh_test::FAILED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: eighth_test::RUNNING', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: eighth_test::PASSED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: ninth_test::RUNNING', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: ninth_test::PASSED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: tenth_test::RUNNING', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: tenth_test::PASSED', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: eleventh_test::RUNNING', 'run.log')
            expect_string(br'INFO:  \[0\]\[dut_ut\]: eleventh_test::PASSED', 'run.log')
            expect_string(br'INFO:  \[0\]\[testrunner\]: FAILED', 'run.log')
