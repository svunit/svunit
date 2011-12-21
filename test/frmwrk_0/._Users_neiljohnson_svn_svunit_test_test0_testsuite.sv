//****************************************************************
// Copyright (c) 2008 XtremeEDA Corp. All Rights Reserved
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// File            : ._Users_neiljohnson_svn_svunit_test_test0_testsuite.sv
//
// Description     : Test Suite File
//
// Created         : <DATE>
//
// Original Author : <AUTHOR>
//
//****************************************************************
import svunit_pkg::*;

module _Users_neiljohnson_svn_svunit_test_test0_testsuite;
  string name = "_Users_neiljohnson_svn_svunit_test_test0_ts";

  //===================
  // Test suite master
  //===================
  svunit_testsuite svunit_ts;

  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  test_unit_test test_ut();


  //===================================
  // Setup
  //===================================
  function void setup();
    test_ut.setup();
    svunit_ts = new(name);
    svunit_ts.add_testcase(test_ut.unittest);
  endfunction

endmodule


