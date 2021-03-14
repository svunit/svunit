import fileinput
import subprocess
import pathlib

import xml.etree.ElementTree as ET

from utils import *


@all_files_in_dir('junit-xml/single-test-suite')
@all_available_simulators()
def test_single_test_suite(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        assert pathlib.Path('tests.xml').exists()
        tree = ET.parse('tests.xml')
        root = tree.getroot()
        assert root.tag == 'testsuites'
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
        assert pathlib.Path('tests.xml').exists()
        tree = ET.parse('tests.xml')
        root = tree.getroot()
        assert root.tag == 'testsuites'
        assert len(list(root)) == 3

        assert any(ts.attrib['name'] == '__ts' for ts in list(root))
        assert any(ts.attrib['name'] == '__group0_ts' for ts in list(root))
        assert any(ts.attrib['name'] == '__group1_ts' for ts in list(root))
