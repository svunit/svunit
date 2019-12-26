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


@pytest.mark.datafiles(
        os.path.join(FIXTURE_DIR, 'frmwrk_4', 'test.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_4', 'another_test'),
        keep_top_dir=True,
        )
def test_frmwrk_4(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')
        with (datafiles / 'another_test').as_cwd():
            create_unit_test('test0.sv')
        subprocess.check_call(['buildSVUnit'])

        golden_testrunner_with_2_testsuites()

        verify_testrunner('testrunner.gold', '__another_test', '_')


@pytest.mark.datafiles(
        os.path.join(FIXTURE_DIR, 'frmwrk_6', 'test.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_6', 'subdir0'),
        os.path.join(FIXTURE_DIR, 'frmwrk_6', 'subdir1'),
        keep_top_dir=True,
        )
def test_frmwrk_6(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './test_unit_test.sv', 'test.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir0/subdir0_unit_test.sv', './subdir0/subdir0.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1_unit_test.sv', './subdir1/subdir1.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1a/subdir1a_unit_test.sv', './subdir1/subdir1a/subdir1a.sv'])

        subprocess.check_call(['buildSVUnit'])

        golden_testrunner_with_4_testsuites()

        verify_testrunner('testrunner.gold', '__subdir0', '__subdir1_subdir1a', '__subdir1', '_')


def test_frmwrk_7(tmpdir):
    with tmpdir.as_cwd():
        return_code = subprocess.call(['buildSVUnit'])
        assert return_code == 1

        # verify no new files were created
        assert not tmpdir.listdir()


@pytest.mark.datafiles(
        os.path.join(FIXTURE_DIR, 'frmwrk_8', 'subdir0'),
        os.path.join(FIXTURE_DIR, 'frmwrk_8', 'subdir1'),
        keep_top_dir=True,
        )
def test_frmwrk_8(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir0/subdir0_unit_test.sv', './subdir0/subdir0.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1_unit_test.sv', './subdir1/subdir1.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1a/subdir1a_unit_test.sv', './subdir1/subdir1a/subdir1a.sv'])

        subprocess.check_call(['buildSVUnit'])

        golden_testrunner_with_3_testsuites()

        verify_testrunner('testrunner.gold', '__subdir0', '__subdir1_subdir1a', '__subdir1')


@pytest.mark.datafiles(
        os.path.join(FIXTURE_DIR, 'frmwrk_9', 'test.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_9', 'subdir1'),
        keep_top_dir=True,
        )
def test_frmwrk_9(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './test_unit_test.sv', 'test.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1a/subdir1a_unit_test.sv', './subdir1/subdir1a/subdir1a.sv'])

        subprocess.check_call(['buildSVUnit'])

        golden_testrunner_with_2_testsuites()

        verify_testrunner('testrunner.gold', '__subdir1_subdir1a', '_')


@pytest.mark.datafiles(os.path.join(FIXTURE_DIR, 'frmwrk_10', 'test.sv'))
def test_frmwrk_10(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', 'test.sv'])

        golden_module_unit_test('test', 'test')

        verify_file('test_unit_test.gold', 'test_unit_test.sv')


@pytest.mark.datafiles(os.path.join(FIXTURE_DIR, 'frmwrk_11', 'test_if.sv'))
def test_frmwrk_11(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', 'test_if.sv'])

        golden_if_unit_test('test_if', 'test_if')

        verify_file('test_if_unit_test.gold', 'test_if_unit_test.sv')


@pytest.mark.datafiles(
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test-hij.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test-xyz.abc'),
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test.sv.abc'),
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test.xyz'),
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test.xyz.abc'),
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test1'),
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test2.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_12', 'test3.v'),
        )
def test_frmwrk_12(datafiles):
    with datafiles.as_cwd():
        for file in datafiles.listdir():
            subprocess.check_call(['create_unit_test.pl', file])
            assert pathlib.Path(file.purebasename + '_unit_test.sv').is_file()


@pytest.mark.datafiles(
        os.path.join(FIXTURE_DIR, 'frmwrk_13', 'test-hij.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_13', 'test.sv.abc'),
        os.path.join(FIXTURE_DIR, 'frmwrk_13', 'test1'),
        os.path.join(FIXTURE_DIR, 'frmwrk_13', 'test2.sv'),
        os.path.join(FIXTURE_DIR, 'frmwrk_13', 'test3.v'),
        os.path.join(FIXTURE_DIR, 'frmwrk_13', 'second_dir'),
        keep_top_dir=True,
        )
def test_frmwrk_13(datafiles):
    with datafiles.as_cwd():
        for file in (datafiles / 'second_dir').listdir():
            if not file.check(file=1):
                continue
            subprocess.check_call(['create_unit_test.pl', file])
            assert pathlib.Path(file.purebasename + '_unit_test.sv').is_file()

    with (datafiles / 'second_dir').as_cwd():
        for file in datafiles.listdir():
            if not file.check(file=1):
                continue
            subprocess.check_call(['create_unit_test.pl', file])
            assert pathlib.Path(file.purebasename + '_unit_test.sv').is_file()
