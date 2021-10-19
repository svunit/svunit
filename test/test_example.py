import subprocess
import pathlib

import pytest

from utils import *


EXAMPLES_DIR = pathlib.Path(os.environ['SVUNIT_INSTALL']) / 'examples'


@all_files_in_dir((EXAMPLES_DIR / 'modules/apb_slave').as_posix())
@all_available_simulators()
def test_example_modules_apb_slave(datafiles, simulator):
    expect_passing_example(datafiles, simulator)


@all_files_in_dir((EXAMPLES_DIR / 'uvm/uvm_report_mock').as_posix())
@all_available_simulators()
def test_example_uvm_report_mock(datafiles, simulator):
    expect_passing_example(datafiles, simulator, ['-uvm', '-define', 'RUN_SVUNIT_WITH_UVM_REPORT_MOCK'])


@all_files_in_dir((EXAMPLES_DIR / 'uvm/simple_model').as_posix())
@all_available_simulators()
def test_example_uvm_simple_model(datafiles, simulator):
    if simulator == 'dsim':
        pytest.skip("Issue when running with 'dsim' that needs to be debugged")
    expect_passing_example(datafiles, simulator, ['-uvm'])


# TODO Remove this is the same test as 'simple_model'. Not sure why this exists.
@all_files_in_dir((EXAMPLES_DIR / 'uvm/simple_model').as_posix())
@all_available_simulators()
def test_example_uvm_simple_model_2(datafiles, simulator):
    if simulator == 'dsim':
        pytest.skip("Issue when running with 'dsim' that needs to be debugged")
    expect_passing_example(datafiles, simulator, ['-uvm'])


@all_files_in_dir((EXAMPLES_DIR / 'uvm/uvm_express').as_posix())
@all_available_simulators()
def test_example_uvm_uvm_express(datafiles, simulator):
    if simulator == 'irun':
        expect_passing_example(datafiles, simulator, ['-U', '--filelist', 'cov.f', '-define', 'CLK_PERIOD=10ns'])
    if simulator == 'qverilog':
        expect_passing_example(datafiles, simulator, ['-U', '-define', 'CLK_PERIOD=10ns'])
