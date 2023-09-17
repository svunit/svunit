import contextlib
import mmap
import os
import pathlib
import re
import shutil
import subprocess
import warnings

import pytest


@contextlib.contextmanager
def working_directory(path):
    """Changes working directory and returns to previous on exit."""
    prev_cwd = pathlib.Path.cwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)


def all_files_in_dir(dirname):
    dirpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), dirname)
    return pytest.mark.datafiles(
            *pathlib.Path(dirpath).iterdir(),
            keep_top_dir=True,
            )

def all_available_simulators():
    simulators = []

    if shutil.which('irun'):
        simulators.append('irun')
    if shutil.which('xrun'):
        simulators.append('xrun')
    if shutil.which('vcs'):
        simulators.append('vcs')
    if shutil.which('vlog'):
        simulators.append('modelsim')
    if shutil.which('dsim'):
        simulators.append('dsim')
    if shutil.which('qrun'):
        simulators.append('qrun')
    if shutil.which('verilator'):
        simulators.append('verilator')

    if not simulators:
        warnings.warn('None of irun, modelsim, vcs, dsim, qrun or verilator are in your path. You need at least 1 simulator to regress svunit-code!')

    return pytest.mark.parametrize("simulator", simulators)


def clean_paths(rm_paths):
    for rm_path in rm_paths:
        for p in pathlib.Path('.').glob(rm_path):
            p.unlink()


def create_unit_test(name):
    subprocess.check_call(['create_unit_test.pl', name])


def get_svunit_root():
    return os.path.dirname(os.path.dirname(os.path.realpath(__file__)))


def golden_class_unit_test(FILE, MYNAME):
    template = open('{}/test/templates/class_unit_test.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('{}_unit_test.gold'.format(FILE), 'w') as output:
        for line in template:
            output.write(line.replace('FILE', FILE).replace('MYNAME', MYNAME))

def golden_module_unit_test(FILE, MYNAME):
    template = open('{}/test/templates/module_unit_test.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('{}_unit_test.gold'.format(FILE), 'w') as output:
        for line in template:
            output.write(line.replace('FILE', FILE).replace('MYNAME', MYNAME))

def golden_if_unit_test(FILE, MYNAME):
    template = open('{}/test/templates/if_unit_test.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('{}_unit_test.gold'.format(FILE), 'w') as output:
        for line in template:
            output.write(line.replace('FILE', FILE).replace('MYNAME', MYNAME))

def golden_testsuite_with_1_unittest(MYNAME):
    template = open('{}/test/templates/testsuite_with_1_unittest.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('testsuite.gold', 'w') as output:
        for line in template:
            output.write(line.replace('MYNAME', MYNAME))

def golden_testsuite_with_2_unittests(MYNAME1, MYNAME2):
    template = open('{}/test/templates/testsuite_with_2_unittest.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('testsuite.gold', 'w') as output:
        for line in template:
            output.write(line.replace('MYNAME1', MYNAME1).replace('MYNAME2', MYNAME2))

def golden_testrunner_with_1_testsuite():
    template = open('{}/test/templates/testrunner_with_1_testsuite.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('testrunner.gold', 'w') as output:
        for line in template:
            output.write(line)

def golden_testrunner_with_2_testsuites():
    template = open('{}/test/templates/testrunner_with_2_testsuite.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('testrunner.gold', 'w') as output:
        for line in template:
            output.write(line)

def golden_testrunner_with_3_testsuites():
    template = open('{}/test/templates/testrunner_with_3_testsuite.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('testrunner.gold', 'w') as output:
        for line in template:
            output.write(line)

def golden_testrunner_with_4_testsuites():
    template = open('{}/test/templates/testrunner_with_4_testsuite.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('testrunner.gold', 'w') as output:
        for line in template:
            output.write(line)


def verify_file(file0, file1):
    result = subprocess.run(['diff', '-wbB', file0, file1], stdout=subprocess.PIPE)
    assert result.returncode in [0, 1]
    if result.returncode == 1:
        assert result.stdout == b''

def verify_testsuite(testsuite, dir=''):
    PWD = '_'
    file = open(testsuite)
    with open('.{}'.format(testsuite), 'w') as output:
        for line in file:
            output.write(line.replace('PWD', "{}{}".format(PWD, dir)))
    verify_file(output.name, '.{}{}_testsuite.sv'.format(PWD, dir))

def verify_testrunner(testrunner, ts0, ts1='', ts2='', ts3='', tr=''):
    if tr == '':
        tr = '.testrunner.sv'
    file = open(testrunner)
    with open('.{}'.format(testrunner), 'w') as output:
        for line in file:
            output.write(line.replace('TS0', ts0).replace('TS1', ts1).replace('TS2', ts2).replace('TS3', ts3))
    verify_file(output.name, tr)


def expect_testrunner_pass(logfile_path):
    expect_string(br'INFO:  \[.*\]\[testrunner\]: PASSED \(. of . suites passing\) \[.*\]', logfile_path)

def expect_testrunner_fail(logfile_path):
    expect_string(br'INFO:  \[.*\]\[testrunner\]: FAILED', logfile_path)

def expect_string(pattern, logfile_path):
    with open(logfile_path) as file, mmap.mmap(file.fileno(), 0, access=mmap.ACCESS_READ) as log:
        assert re.search(pattern, log), "\"%s\" not found at %s log file" % (pattern, logfile_path)

def expect_file(path):
    return os.path.exists(path)

def expect_file_does_contain(pattern, file_path):
    return expect_string(pattern, file_path)


def expect_passing_example(dir, sim, args=[]):
    with dir.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', sim] + args)

        expect_file('run.log')
        expect_testrunner_pass('run.log')


def contains_pattern(pattern, logfile_path):
    with open(logfile_path) as file, mmap.mmap(file.fileno(), 0, access=mmap.ACCESS_READ) as log:
        return bool(re.search(pattern, log))


class FakeTool:

    @classmethod
    def that_fails(cls, name):
        executable = pathlib.Path(name)
        log_file = 'fake_tool.log'
        script = [
                'echo "{} called" > {}'.format(name, log_file),
                'exit 1'.format(log_file),
                ]
        executable.write_text('\n'.join(script))
        executable.chmod(0o700)
        return executable


    @classmethod
    def that_succeeds(cls, name):
        executable = pathlib.Path(name)
        log_file = 'fake_tool.log'
        script = [
                'echo "{} called" > {}'.format(name, log_file),
                'exit 0'.format(log_file),
                ]
        executable.write_text('\n'.join(script))
        executable.chmod(0o700)
        return executable
