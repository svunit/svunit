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



def test_filter_wildcards(tmp_path):
    failing_unit_test = tmp_path.joinpath('some_failing_unit_test.sv')
    failing_unit_test.write_text('''
module some_failing_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "some_failing_ut";
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

    passing_unit_test = tmp_path.joinpath('some_passing_unit_test.sv')
    passing_unit_test.write_text('''
module some_passing_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "some_passing_ut";
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
      `FAIL_IF(0)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
    ''')
    log = tmp_path.joinpath('run.log')

    print('Filtering only the passing testcase should block the fail')
    subprocess.check_call(['runSVUnit', '--filter', 'some_passing_ut.*'], cwd=tmp_path)
    assert 'FAILED' not in log.read_text()
    assert 'some_test' in log.read_text()

    print('Filtering only for the test should cause both tests to run, hence trigger the fail')
    subprocess.check_call(['runSVUnit', '--filter', "*.some_test"], cwd=tmp_path)
    assert 'FAILED' in log.read_text()


def test_filter_without_dot(tmp_path):
    dummy_unit_test = tmp_path.joinpath('dummy_unit_test.sv')
    dummy_unit_test.write_text('''
module dummy_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "some_passing_ut";
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
  `SVUNIT_TESTS_END

endmodule
    ''')

    subprocess.check_call(['runSVUnit', '--filter', 'some_string'], cwd=tmp_path)

    log = tmp_path.joinpath('run.log')
    assert 'fatal' in log.read_text()



def test_filter_with_extra_dot(tmp_path):
    dummy_unit_test = tmp_path.joinpath('dummy_unit_test.sv')
    dummy_unit_test.write_text('''
module dummy_unit_test;

  import svunit_pkg::*;
  `include "svunit_defines.svh"

  string name = "some_passing_ut";
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
  `SVUNIT_TESTS_END

endmodule
    ''')

    subprocess.check_call(['runSVUnit', '--filter', 'a.b.c'], cwd=tmp_path)

    log = tmp_path.joinpath('run.log')
    assert 'fatal' in log.read_text()
