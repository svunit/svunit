import subprocess

import pytest


def test_filter(tmp_path):
    unit_test = tmp_path.joinpath('some_unit_test.sv')
    unit_test.write_text('''
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

    `SVTEST(some_failing_test)
      `FAIL_IF(1)
    `SVTEST_END

    `SVTEST(some_passing_test)
      `FAIL_IF(0)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
    ''')

    log = tmp_path.joinpath('run.log')

    print('Filtering only the passing test should block the fail')
    subprocess.check_call(['runSVUnit', '--filter', 'some_ut.some_passing_test'], cwd=tmp_path)
    assert 'FAILED' not in log.read_text()

    print('No explicit filter should cause both tests to run, hence trigger the fail')
    subprocess.check_call(['runSVUnit'], cwd=tmp_path)
    assert 'FAILED' in log.read_text()
