//###########################################################################
//
//  Copyright 2011 The SVUnit Authors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//###########################################################################

`include "svunit_defines.svh"

package svunit_pkg;

`ifdef SVUNIT_VERSION
  const string svunit_version = `SVUNIT_VERSION;
`else
  const string svunit_version = "For SVUnit Version info, see: $SVUNIT_INSTALL/VERSION.txt";
`endif

  typedef class svunit_testcase;

  `include "svunit_types.svh"
  `include "svunit_base.sv"
  `include "svunit_globals.svh"
  `include "svunit_testcase.sv"
  `include "svunit_testcase_wrp.sv"
  `include "svunit_testsuite.sv"
  `include "svunit_testrunner.sv"
endpackage
