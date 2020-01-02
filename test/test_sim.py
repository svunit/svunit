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


@all_files_in_dir('sim_4')
def test_sim_4(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '--sim', s, '--log', 'other.log', '--define', 'DIDLEY_SQUAT', '-d', 'FIDDLE_FADDLE="junk"'])

            expect_file('other.log')
            expect_file_does_contain(br'defined DIDLEY_SQUAT', 'other.log')
            expect_file_does_contain(br'junk', 'other.log')
            expect_testrunner_pass('other.log')


@all_files_in_dir('sim_5')
def test_sim_5(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s, '-r', '+JOKES +DUD=4', '--r_arg', '+BOZO'])

            expect_testrunner_pass('run.log')


@all_files_in_dir('sim_6')
def test_sim_6(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s, '-c', '+define+JOKES +define+DUD=4', '--c_arg', '+define+BOZO'])

            expect_testrunner_pass('run.log')


@all_files_in_dir('sim_7')
def test_sim_7(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s, '-o', 'rundir'])

            expect_testrunner_pass('rundir/run.log')


@all_files_in_dir('sim_8')
def test_sim_8(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s, '-f', 'my_filelist.f', '--filelist', 'a_filelist.f'])

            expect_testrunner_pass('run.log')


@all_files_in_dir('sim_9')
def test_sim_9(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s, '-f', os.path.abspath( 'my_filelist.f'), '--filelist', os.path.abspath('a_filelist.f'), '-o', '.'])

            expect_testrunner_pass('./run.log')


@all_files_in_dir('sim_10')
def test_sim_10(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s])

            expect_string(br'INFO:  \[0\]\[dut_ut\]: Use the INFO macro', 'run.log')
            expect_string(br'ERROR: \[0\]\[dut_ut\]: Use the ERROR macro', 'run.log')
            expect_string(br'strictly_so_the_teardown_is_called::FAILED', 'run.log')
            expect_string(br'fail_if::FAILED', 'run.log')
            expect_string(br'fail_unless::FAILED', 'run.log')
            expect_string(br'fail_if_equal::PASSED', 'run.log')
            expect_string(br'fail_unless_equal::FAILED', 'run.log')
            expect_testrunner_fail('run.log')


@all_files_in_dir('sim_11')
def test_sim_11(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s])

            expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_unless_str_equal: \"abd\" != \"abcd\"', 'run.log')
            expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_if_str_equal: \"abcd\" == \"abcd\"', 'run.log')
            expect_testrunner_fail('run.log')


@all_files_in_dir('sim_12')
def test_sim_12(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            if s == 'vcs':
                print('WARNING: VCS mixed language simulation requires multistage compilation.')
                print('         Unfortunately, it has not been implemented yet.')
                print('         Skipping the test...')
                continue

            subprocess.check_call(['runSVUnit', '-s', s, '-m', 'vhdl.f'])

            expect_testrunner_pass('run.log')
