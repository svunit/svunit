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


@all_files_in_dir('frmwrk_0')
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


@all_files_in_dir('frmwrk_1')
def test_frmwrk_1(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')

        golden_class_unit_test('test', 'test0')

        verify_file('test_unit_test.gold', 'test_unit_test.sv')


@all_files_in_dir('frmwrk_2')
def test_frmwrk_2(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')

        golden_class_unit_test('test', 'virtual_test')

        verify_file('test_unit_test.gold', 'test_unit_test.sv')


@all_files_in_dir('frmwrk_3')
def test_frmwrk_3(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')
        subprocess.check_call(['buildSVUnit'])

        verify_file('test_unit_test.gold', 'test_unit_test.sv')
        verify_testsute('testsuite.gold')


@all_files_in_dir('frmwrk_4')
def test_frmwrk_4(datafiles):
    with datafiles.as_cwd():
        create_unit_test('test.sv')
        with (datafiles / 'another_test').as_cwd():
            create_unit_test('test0.sv')
        subprocess.check_call(['buildSVUnit'])

        golden_testrunner_with_2_testsuites()

        verify_testrunner('testrunner.gold', '__another_test', '_')


@all_files_in_dir('frmwrk_6')
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


@all_files_in_dir('frmwrk_8')
def test_frmwrk_8(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir0/subdir0_unit_test.sv', './subdir0/subdir0.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1_unit_test.sv', './subdir1/subdir1.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1a/subdir1a_unit_test.sv', './subdir1/subdir1a/subdir1a.sv'])

        subprocess.check_call(['buildSVUnit'])

        golden_testrunner_with_3_testsuites()

        verify_testrunner('testrunner.gold', '__subdir0', '__subdir1_subdir1a', '__subdir1')


@all_files_in_dir('frmwrk_9')
def test_frmwrk_9(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './test_unit_test.sv', 'test.sv'])
        subprocess.check_call(['create_unit_test.pl', '-overwrite', '-out', './subdir1/subdir1a/subdir1a_unit_test.sv', './subdir1/subdir1a/subdir1a.sv'])

        subprocess.check_call(['buildSVUnit'])

        golden_testrunner_with_2_testsuites()

        verify_testrunner('testrunner.gold', '__subdir1_subdir1a', '_')


@all_files_in_dir('frmwrk_10')
def test_frmwrk_10(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', 'test.sv'])

        golden_module_unit_test('test', 'test')

        verify_file('test_unit_test.gold', 'test_unit_test.sv')


@all_files_in_dir('frmwrk_11')
def test_frmwrk_11(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-overwrite', 'test_if.sv'])

        golden_if_unit_test('test_if', 'test_if')

        verify_file('test_if_unit_test.gold', 'test_if_unit_test.sv')


@all_files_in_dir('frmwrk_12')
def test_frmwrk_12(datafiles):
    with datafiles.as_cwd():
        for file in datafiles.listdir():
            subprocess.check_call(['create_unit_test.pl', file])
            assert pathlib.Path(file.purebasename + '_unit_test.sv').is_file()


@all_files_in_dir('frmwrk_13')
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


@pytest.mark.skip(reason='Setup.csh is busted')
@all_files_in_dir('frmwrk_14')
def test_frmwrk_14(datafiles):
    new_env = os.environ.copy()
    path_entries = new_env['PATH'].split(':')
    new_path_entries = [path_entry for path_entry in path_entries if not 'svunit-code' in path_entry]
    new_env['PATH'] = ':'.join(new_path_entries)
    new_env['SVUNIT_ROOT'] = get_svunit_root()

    with datafiles.as_cwd():
        simulators = get_simulators()
        for simulator in simulators:
            subprocess.check_call(['csh', 'run.csh', simulator], env=new_env)
            subprocess.check_call(['tcsh', 'run.csh', simulator], env=new_env)


@all_files_in_dir('frmwrk_15')
def test_frmwrk_15(datafiles):
    with datafiles.as_cwd():
        os.mkdir('third_dir')
        for file in (datafiles / 'second_dir').listdir():
            if not file.check(file=1):
                continue
            destfile = os.path.join('third_dir', file.purebasename + '_unit_test.sv')
            subprocess.check_call(['create_unit_test.pl', file, '-out', destfile])
            assert pathlib.Path(destfile).is_file()

    with (datafiles / 'second_dir').as_cwd():
        for file in (datafiles / 'second_dir').listdir():
            if not file.check(file=1):
                continue
            destfile = os.path.join('..', file.purebasename + '_unit_test.sv')
            subprocess.check_call(['create_unit_test.pl', file, '-out', destfile])
            assert pathlib.Path(destfile).is_file()

    with datafiles.as_cwd():
        subprocess.check_call(['create_unit_test.pl', '-out', 'dud_unit_test.v', 'test2.sv'])
        assert not pathlib.Path('dud_unit_test.v').is_file()

        subprocess.check_call(['create_unit_test.pl', '-out', 'dud.v', 'test2.sv'])
        assert not pathlib.Path('dud.v').is_file()
