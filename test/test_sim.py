import fileinput
import subprocess
import pathlib

from utils import *


@all_files_in_dir('sim_0')
@all_available_simulators()
def test_sim_0(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        subprocess.check_call(['runSVUnit', '-s', simulator])
        expect_testrunner_pass('run.log')


@all_files_in_dir('sim_1')
@all_available_simulators()
def test_sim_1(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        subprocess.check_call(['runSVUnit', '-s', simulator])
        expect_testrunner_pass('run.log')


@all_files_in_dir('sim_2')
@all_available_simulators()
def test_sim_2(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        subprocess.check_call(['runSVUnit', '-s', simulator])
        expect_testrunner_pass('run.log')


@all_files_in_dir('sim_3')
@all_available_simulators()
def test_sim_3(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])

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
        expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_if: foo != 1 \(at .*dut_unit_test.sv line:.*\)', 'run.log')
        expect_string(br'INFO:  \[0\]\[dut_ut\]: x_as_fail_if_expression::FAILED', 'run.log')
        expect_string(br'INFO:  \[0\]\[testrunner\]: FAILED', 'run.log')


@all_files_in_dir('sim_4')
@all_available_simulators()
def test_sim_4(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '--sim', simulator, '--log', 'other.log', '--define', 'DIDLEY_SQUAT', '-d', 'FIDDLE_FADDLE="junk"'])

        expect_file('other.log')
        expect_file_does_contain(br'defined DIDLEY_SQUAT', 'other.log')
        expect_file_does_contain(br'junk', 'other.log')
        expect_testrunner_pass('other.log')


@all_files_in_dir('sim_5')
@all_available_simulators()
def test_sim_5(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator, '-r', '+JOKES +DUD=4', '--r_arg', '+BOZO'])

        expect_testrunner_pass('run.log')


@all_files_in_dir('sim_6')
@all_available_simulators()
def test_sim_6(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator, '-c', '+define+JOKES +define+DUD=4', '--c_arg', '+define+BOZO'])

        expect_testrunner_pass('run.log')


@all_files_in_dir('sim_7')
@all_available_simulators()
def test_sim_7(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator, '-o', 'rundir'])

        expect_testrunner_pass('rundir/run.log')


@all_files_in_dir('sim_8')
@all_available_simulators()
def test_sim_8(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', '-dut_unit_test.sv', 'dut.sv'])

        subprocess.check_call(['runSVUnit', '-s', simulator, '-f', 'my_filelist.f', '--filelist', 'a_filelist.f'])

        expect_testrunner_pass('run.log')


@all_files_in_dir('sim_9')
@all_available_simulators()
def test_sim_9(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator, '-f', os.path.abspath( 'my_filelist.f'), '--filelist', os.path.abspath('a_filelist.f'), '-o', '.'])

        expect_testrunner_pass('./run.log')


@all_files_in_dir('sim_10')
@all_available_simulators()
def test_sim_10(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])

        expect_string(br'INFO:  \[0\]\[dut_ut\]: Use the INFO macro', 'run.log')
        expect_string(br'ERROR: \[0\]\[dut_ut\]: Use the ERROR macro', 'run.log')
        expect_string(br'strictly_so_the_teardown_is_called::FAILED', 'run.log')
        expect_string(br'fail_if::FAILED', 'run.log')
        expect_string(br'fail_unless::FAILED', 'run.log')
        expect_string(br'fail_if_equal::PASSED', 'run.log')
        expect_string(br'fail_unless_equal::FAILED', 'run.log')
        expect_testrunner_fail('run.log')


@all_files_in_dir('sim_11')
@all_available_simulators()
def test_sim_11(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])

        expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_unless_str_equal: \"abd\" != \"abcd\"', 'run.log')
        expect_string(br'ERROR: \[0\]\[dut_ut\]: fail_if_str_equal: \"abcd\" == \"abcd\"', 'run.log')
        expect_testrunner_fail('run.log')


@all_files_in_dir('sim_12')
@all_available_simulators()
def test_sim_12(datafiles, simulator):
    with datafiles.as_cwd():
        if simulator == 'vcs':
            print('WARNING: VCS mixed language simulation requires multistage compilation.')
            print('         Unfortunately, it has not been implemented yet.')
            print('         Skipping the test...')
            return

        subprocess.check_call(['runSVUnit', '-s', simulator, '-m', 'vhdl.f'])

        expect_testrunner_pass('run.log')


@all_files_in_dir('sim_13')
@all_available_simulators()
def test_sim_13(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])

        expect_string(br"ERROR: \[50\]\[dut_ut\]: fail_if: svunit_timeout (at `pwd`/./dut_unit_test.sv line:62)", 'run.log')
        expect_string(br"INFO:  \[99\]\[dut_ut\]: no_timeout::PASSED", 'run.log')

@all_files_in_dir('sim_14')
@all_available_simulators()
def test_sim_14(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])

        expect_string(br"ERROR: \[0\]\[dut_ut\]: fail_if: 1 \(at *./dut_unit_test.sv line:46\)", 'run.log')
        expect_string(br"ERROR: \[0\]\[dut_ut\]: fail_if: 1 \(at *./dut_unit_test.sv line:69\)", 'run.log')

@all_files_in_dir('fail_macros')
@all_available_simulators()
def test_fail_macros(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])

        assert not contains_pattern(br"went into 'else' block", 'run.log')
