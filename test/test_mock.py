import subprocess
from test_utils import *


@all_files_in_dir('mock_uvm_report')
def test_mock_uvm_report(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-sim', s, '-uvm', '-define', 'UVM_NO_DEPRECATED', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])
            expect_testrunner_pass('run.log')
