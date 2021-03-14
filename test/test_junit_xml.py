import fileinput
import subprocess
import pathlib

import xml.etree.ElementTree as ET

from utils import *


@all_files_in_dir('junit-xml/single-test-suite')
@all_available_simulators()
def test_writes_junit_xml(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        assert pathlib.Path('tests.xml').exists()
        tree = ET.parse('tests.xml')
        root = tree.getroot()
        assert root.tag == 'testsuites'


@all_files_in_dir('junit-xml/single-test-suite')
@all_available_simulators()
def test_single_test_suite(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        root = ET.parse('tests.xml').getroot()
        assert len(list(root)) == 1

        testsuite = root[0]
        assert testsuite.tag == 'testsuite'
        assert 'name' in testsuite.attrib
        assert testsuite.attrib['name'] == '__ts'


@all_files_in_dir('junit-xml/multiple-test-suites')
@all_available_simulators()
def test_multiple_test_suites(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        root = ET.parse('tests.xml').getroot()
        assert len(list(root)) == 3

        assert any(ts.attrib['name'] == '__ts' for ts in list(root))
        assert any(ts.attrib['name'] == '__group0_ts' for ts in list(root))
        assert any(ts.attrib['name'] == '__group1_ts' for ts in list(root))


@all_files_in_dir('junit-xml/single-passing-test')
@all_available_simulators()
def test_single_passing_test(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        root = ET.parse('tests.xml').getroot()
        test_suite = root[0]
        assert len(list(test_suite)) == 1

        test_case = root[0][0]
        assert test_case.tag == 'testcase'
        assert 'name' in test_case.attrib
        assert test_case.attrib['name'] == 'passing_test'
        assert 'classname' in test_case.attrib
        assert test_case.attrib['classname'] == 'dummy_ut'


@all_files_in_dir('junit-xml/multiple-passing-tests')
@all_available_simulators()
def test_multiple_passing_tests(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        root = ET.parse('tests.xml').getroot()
        test_suite = root[0]

        assert len(list(test_suite)) == 2
        assert any(ts.attrib['name'] == 'passing_test0' for ts in list(test_suite))
        assert any(ts.attrib['name'] == 'passing_test1' for ts in list(test_suite))


@all_files_in_dir('junit-xml/multiple-test-modules')
@all_available_simulators()
def test_multiple_test_modules(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        root = ET.parse('tests.xml').getroot()
        test_suite = root[0]

        assert len(list(test_suite)) == 2
        assert any(ts.attrib['classname'] == 'dummy0_ut' for ts in list(test_suite))
        assert any(ts.attrib['classname'] == 'dummy1_ut' for ts in list(test_suite))


@all_files_in_dir('junit-xml/single-failing-test')
@all_available_simulators()
def test_single_failing_test(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        root = ET.parse('tests.xml').getroot()
        test_suite = root[0]
        test_case = test_suite[0]

        assert len(list(test_case)) == 1
        assert test_case[0].tag == 'failure'
        assert test_case[0].attrib['type'] == 'failure'
        assert 'fail_if' in test_case[0].attrib['message']


@all_files_in_dir('junit-xml/multiple-failing-tests')
@all_available_simulators()
def test_multiple_failing_tests(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        root = ET.parse('tests.xml').getroot()
        test_suite = root[0]
        assert len(list(test_suite)) == 2
        failing_test0 = next(tc for tc in list(test_suite) if tc.attrib['name'] == 'failing_test0')
        assert 'fail_if' in failing_test0[0].attrib['message']
        failing_test1 = next(tc for tc in list(test_suite) if tc.attrib['name'] == 'failing_test1')
        assert 'fail_unless' in failing_test1[0].attrib['message']
