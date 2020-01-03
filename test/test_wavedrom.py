import subprocess
from utils import *


@all_files_in_dir('wavedrom_0')
def test_wavedrom_0(datafiles):
    with datafiles.as_cwd():
        subprocess.check_call(['python3', 'wavedrom-test.py'])
