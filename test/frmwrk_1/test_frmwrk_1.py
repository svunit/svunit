import os
import pathlib
import subprocess


def setup_module():
    rm_paths = [
        '.*testsuite.sv',
        '.testrunner.gold',
        '.testrunner.gold.tmp',
        '.testrunner.sv',
        '.svunit_top.sv',
        '.testsuite.gold',
        '.testsuite.gold.tmp',
        'test_unit_test.sv',
        'test_unit_test.gold',
        ]
    for rm_path in rm_paths:
        for p in pathlib.Path('.').glob(rm_path):
            p.unlink()


def test_dummy():
    create_unit_test('test.sv')

    golden_class_unit_test('test', 'test0')

    verify_file('test_unit_test.gold', 'test_unit_test.sv')


def create_unit_test(name):
    subprocess.check_call(['create_unit_test.pl', name])


def golden_class_unit_test(FILE, MYNAME):
    template = open('{}/test/templates/class_unit_test.gold'.format(os.environ['SVUNIT_INSTALL']))
    with open('{}_unit_test.gold'.format(FILE), 'w') as output:
        for line in template:
            output.write(line.replace('FILE', FILE).replace('MYNAME', MYNAME))


def verify_file(file0, file1):
    result = subprocess.run(['diff', '-wbB', file0, file1], stdout=subprocess.PIPE)
    assert result.returncode in [0, 1]
    if result.returncode == 1:
        assert result.stdout == b''
