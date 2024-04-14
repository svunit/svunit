import subprocess

import pytest

from utils import *


def test_list_tests_option_exists(tmp_path):
    returncode = subprocess.call(
            ['runSVUnit', '--list-tests'],
            cwd=tmp_path)
    assert returncode == 255  # XXX Fix reliance on internal implementation detail: if the script can't run, it quietly returns `255`


@all_available_simulators()
def test_that_tests_are_not_run_when_option_used(simulator, tmp_path):
    some_unit_test = tmp_path.joinpath('some_unit_test.sv')
    some_unit_test.write_text('''
module some_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "some_ut";
  svunit_testcase svunit_ut;

  function void build();
    svunit_ut = new(name);
  endfunction

  task setup();
    svunit_ut.setup();
  endtask

  task teardown();
    svunit_ut.teardown();
  endtask

  `SVUNIT_TESTS_BEGIN

    `SVTEST(some_test)
      `FAIL_IF(1)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
    ''')

    subprocess.check_call(['runSVUnit', '-s', simulator, '--list-tests'], cwd=tmp_path)
    log = tmp_path.joinpath('run.log')
    assert 'FAILED' not in log.read_text()
