import os
import pathlib
import shutil
import subprocess


def clean_paths(rm_paths):
    for rm_path in rm_paths:
        for p in pathlib.Path('.').glob(rm_path):
            p.unlink()


def create_unit_test(name):
    subprocess.check_call(['create_unit_test.pl', name])


def get_simulators():
    result = []

    if shutil.which('irun'):
        result.append('irun')
    if shutil.which('vcs'):
        result.append('vcs')
    if shutil.which('vlog'):
        result.append('modelsim')

    assert result, 'None of irun, modelsim or vcs are in your path. You need at least 1 simulator to regress svunit-code!'

    return result


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
