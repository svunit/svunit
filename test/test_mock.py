import subprocess
from utils import *


@all_files_in_dir('mock_uvm_report')
def test_mock_uvm_report(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            subprocess.check_call(['runSVUnit', '-sim', s, '-uvm', '-define', 'UVM_NO_DEPRECATED', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])
            expect_testrunner_pass('run.log')


# TODO This is redundant with the test that loops over all simulators.
@all_files_in_dir('mock_uvm_report_ius')
def test_mock_uvm_report_ius(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            if s == 'irun':
                subprocess.check_call(['runSVUnit', '-sim', s, '-uvm', '-define', 'UVM_NO_DEPRECATED', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])
                expect_testrunner_pass('run.log')


@all_files_in_dir('mock_uvm_report_ius_uvm1.2')
def test_mock_uvm_report_ius_uvm1_2(datafiles):
    with datafiles.as_cwd():
        for s in get_simulators():
            if s == 'irun':
                subprocess.check_call(['runSVUnit', '-sim', s, '-uvm', '-define', 'UVM_NO_DEPRECATED', '-c_arg', '-uvmhome $INCISIV_HOME/tools/methodology/UVM/CDNS-1.2/sv', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])
                expect_testrunner_pass('run.log')
