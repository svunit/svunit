import subprocess
from utils import *


@all_files_in_dir('util_clk_reset')
def test_mock_uvm_report(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-s', s])
            expect_testrunner_pass('run.log')
