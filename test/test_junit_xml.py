import fileinput
import subprocess
import pathlib

from utils import *


@all_files_in_dir('junit-xml/single-passing-test')
@all_available_simulators()
def test_single_passing_test(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        assert pathlib.Path('tests.xml').exists()
