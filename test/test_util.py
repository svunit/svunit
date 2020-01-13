import subprocess
from utils import *


@all_files_in_dir('util_clk_reset')
@all_available_simulators()
def test_mock_uvm_report(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        expect_testrunner_pass('run.log')
