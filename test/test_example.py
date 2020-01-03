import subprocess
import pathlib
import pytest
from test_utils import *


EXAMPLES_DIR = pathlib.Path(os.environ['SVUNIT_INSTALL']) / 'examples'


def all_files_in_dir(dirname):
    dirpath = os.path.join(os.path.dirname(os.path.realpath(__file__)), dirname)
    return pytest.mark.datafiles(
            *pathlib.Path(dirpath).iterdir(),
            keep_top_dir=True,
            )


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
