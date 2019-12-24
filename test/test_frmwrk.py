import subprocess
import pytest
from test_utils import *


FIXTURE_DIR = os.path.join(
    os.path.dirname(os.path.realpath(__file__)),
    )


@pytest.mark.datafiles(os.path.join(FIXTURE_DIR, 'frmwrk_0', 'test.sv') )
def test_frmwrk_0(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')
        subprocess.check_call(['buildSVUnit'])

        golden_class_unit_test('test', 'test')
        golden_testsuite_with_1_unittest('test')
        golden_testrunner_with_1_testsuite()

        verify_file('test_unit_test.gold', 'test_unit_test.sv')
        verify_testsute('testsuite.gold')
        verify_testrunner('testrunner.gold', '_')


@pytest.mark.datafiles(os.path.join(FIXTURE_DIR, 'frmwrk_1', 'test.sv') )
def test_frmwrk_1(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')

        golden_class_unit_test('test', 'test0')

        verify_file('test_unit_test.gold', 'test_unit_test.sv')


@pytest.mark.datafiles(os.path.join(FIXTURE_DIR, 'frmwrk_2', 'test.sv') )
def test_frmwrk_2(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')

        golden_class_unit_test('test', 'virtual_test')

        verify_file('test_unit_test.gold', 'test_unit_test.sv')


@pytest.mark.datafiles(
        os.path.join(FIXTURE_DIR, 'frmwrk_3', 'test.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_3', 'test_unit_test.gold'),
        os.path.join(FIXTURE_DIR, 'frmwrk_3', 'testsuite.gold'),
        )
def test_frmwrk_3(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')
        subprocess.check_call(['buildSVUnit'])

        verify_file('test_unit_test.gold', 'test_unit_test.sv')
        verify_testsute('testsuite.gold')
