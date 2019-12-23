import pathlib
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
        ])


def test_dummy():
    create_unit_test('test.sv')

    golden_class_unit_test('test', 'test0')

    verify_file('test_unit_test.gold', 'test_unit_test.sv')
