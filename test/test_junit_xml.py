import fileinput
import subprocess
import pathlib

import xml.etree.ElementTree as ET

from utils import *


@all_files_in_dir('junit-xml/single-passing-test')
@all_available_simulators()
def test_single_passing_test(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        assert pathlib.Path('tests.xml').exists()
        tree = ET.parse('tests.xml')
        root = tree.getroot()
        assert root.tag == 'testsuites'
        assert len(list(root)) == 1
        assert root[0].tag == 'testsuite'
        assert 'name' in root[0].attrib
        assert root[0].attrib['name'] == '__ts'
