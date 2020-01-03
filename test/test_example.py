import subprocess
import pathlib
from test_utils import *


EXAMPLES_DIR = pathlib.Path(os.environ['SVUNIT_INSTALL']) / 'examples'


@all_files_in_dir((EXAMPLES_DIR / 'modules/apb_slave').as_posix())
def test_example_modules_apb_slave(datafiles):
    for s in get_simulators():
        expect_passing_example(datafiles, s)


@all_files_in_dir((EXAMPLES_DIR / 'uvm/uvm_report_mock').as_posix())
def test_example_uvm_report_mock(datafiles):
    for s in get_simulators():
        expect_passing_example(datafiles, s, ['-uvm', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])


@all_files_in_dir((EXAMPLES_DIR / 'uvm/simple_model').as_posix())
def test_example_uvm_simple_model(datafiles):
    for s in get_simulators():
        expect_passing_example(datafiles, s, ['-uvm'])


# TODO Remove this is the same test as 'simple_model'. Not sure why this exists.
@all_files_in_dir((EXAMPLES_DIR / 'uvm/simple_model').as_posix())
def test_example_uvm_simple_model_2(datafiles):
    for s in get_simulators():
        expect_passing_example(datafiles, s, ['-uvm'])


@all_files_in_dir((EXAMPLES_DIR / 'uvm/uvm_express').as_posix())
def test_example_uvm_uvm_express(datafiles):
    for s in get_simulators():
        if s == 'irun':
            expect_passing_example(datafiles, s, ['-U', '--filelist', 'cov.f', '-define', 'CLK_PERIOD=10ns'])
        if s == 'qverilog':
            expect_passing_example(datafiles, s, ['-U', '-define', 'CLK_PERIOD=10ns'])
