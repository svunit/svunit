//****************************************************************
// Copyright (c) 2008 XtremeEDA Corp. All Rights Reserved
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// File            : testrunner.sv
//
// Description     : Test Runner
//
// Created         : <DATE>
//
// Original Author : <AUTHOR>
//
//****************************************************************
import svunit_pkg::*;

module testrunner();
  string name = "testrunner";
  svunit_testrunner svunit_tr;

  //===================================
  // These are the tests suites that we
  // want included in this testrunner
  //===================================
  _Users_neiljohnson_svn_svunit_test_test0_testsuite _Users_neiljohnson_svn_svunit_test_test0_ts();


  //===================================
  // Setup
  //===================================
  function void setup();
    svunit_tr = new(name);
    _Users_neiljohnson_svn_svunit_test_test0_ts.setup();
    svunit_tr.add_testsuite(_Users_neiljohnson_svn_svunit_test_test0_ts.svunit_ts);
  endfunction

  task run();
    svunit_tr.run();
  endtask
endmodule
