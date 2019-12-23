import subprocess
import sys

sys.path.append('..')

from test_utils import *


def setup_module():
    clean_paths([
        '.*testsuite.sv',
        '.testrunner.gold',
        '.testrunner.gold.tmp',
        '.testrunner.sv',
        '.svunit_top.sv',
        '.testsuite.gold',
        '.testsuite.gold.tmp',
        'test_unit_test.sv',
        'test_unit_test.gold',
        'testsuite.gold',
        'testrunner.gold',
        '.svunit.f',
        ])


def test_dummy():
    create_unit_test('test.sv')
    subprocess.check_call(['buildSVUnit'])

    golden_class_unit_test('test', 'test')
    golden_testsuite_with_1_unittest('test')
    golden_testrunner_with_1_testsuite()

    verify_file('test_unit_test.gold', 'test_unit_test.sv')
    verify_testsute('testsuite.gold')
    verify_testrunner('testrunner.gold', '_')
