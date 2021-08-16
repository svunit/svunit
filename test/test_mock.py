import subprocess
from utils import *


@all_files_in_dir('mock_uvm_report')
@all_available_simulators()
@pytest.mark.skip(reason="'uvm_report_mock' seems to be busted for UVM 1.2")
def test_mock_uvm_report(datafiles, simulator):
    with datafiles.as_cwd():
        subprocess.check_call(['runSVUnit', '-sim', simulator, '-uvm', '-define', 'UVM_NO_DEPRECATED', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])
        expect_testrunner_pass('run.log')


# TODO This is redundant with the test that loops over all simulators.
@all_files_in_dir('mock_uvm_report_ius')
@all_available_simulators()
def test_mock_uvm_report_ius(datafiles, simulator):
    with datafiles.as_cwd():
        if simulator == 'irun':
            subprocess.check_call(['runSVUnit', '-sim', simulator, '-uvm', '-define', 'UVM_NO_DEPRECATED', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])
            expect_testrunner_pass('run.log')


@all_files_in_dir('mock_uvm_report_ius_uvm1.2')
@all_available_simulators()
@pytest.mark.skip(reason="'uvm_report_mock' seems to be busted for UVM 1.2")
def test_mock_uvm_report_ius_uvm1_2(datafiles, simulator):
    with datafiles.as_cwd():
        if simulator == 'irun':
            subprocess.check_call(['runSVUnit', '-sim', simulator, '-uvm', '-define', 'UVM_NO_DEPRECATED', '-c_arg', '-uvmhome $INCISIV_HOME/tools/methodology/UVM/CDNS-1.2/sv', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])
            expect_testrunner_pass('run.log')
