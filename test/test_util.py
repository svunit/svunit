import subprocess
from utils import *


@all_files_in_dir('util_clk_reset')
@all_available_simulators()
def test_util_clk_reset(datafiles, simulator):
    # TODO Fix code to work in Verilator
    if simulator == 'verilator':
        pytest.skip("Verilator issues a lot of lint warnings for this code")
    if simulator == 'xsim':
        pytest.skip(f"'Include directory added in `svunit.f` by `+incdir+` incompatible with `xvlog`")
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-s', simulator])
        expect_testrunner_pass('run.log')
