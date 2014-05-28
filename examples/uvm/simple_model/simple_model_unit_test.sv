//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################

`include "svunit_defines.svh"

//-----------------------------------------------
// the svunit_uvm_test is required for testing
// uvm_components
//
// UPDATE: the uvm mocks were moved to a package
//         so that package is imported instead
//         of including the svunit_uvm_test.sv
//-----------------------------------------------

//------------------------------------------
// include the dut and the transaction type
//------------------------------------------
`include "simple_model.sv"
`include "simple_xaction.sv"


module simple_model_unit_test;
  import svunit_pkg::svunit_testcase;
  import svunit_uvm_mock_pkg::*;

  string name = "simple_model_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  simple_model my_simple_model;


  //-------------------------------------------
  // for testing purposes, add fifos and ports
  // to interact with the simple_model
  //-------------------------------------------
  uvm_blocking_put_port #(simple_xaction) put_port;
  uvm_tlm_fifo #(simple_xaction) in_fifo;
                                                                                                     
  uvm_tlm_fifo #(simple_xaction) out_fifo;
  uvm_blocking_get_port #(simple_xaction) get_port;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    //---------------------------------------------
    // build an instance of the simple model along
    // with test fifos on the input and output
    //---------------------------------------------
    my_simple_model = simple_model::type_id::create({ name , "::my_simple_model" }, null);

    put_port = new({ name , "::put_port" }, null);
    in_fifo = new({ name , "::in_fifo" }, null);

    out_fifo = new({ name , "::out_fifo" }, null);
    get_port = new({ name , "::get_port" }, null);


    //---------------------------------------------
    // make the connections to the simple model IO
    //---------------------------------------------
    my_simple_model.get_port.connect(in_fifo.get_export);
    put_port.connect(in_fifo.put_export);

    my_simple_model.put_port.connect(out_fifo.put_export);
    get_port.connect(out_fifo.get_export);


    //------------------------------------------------------
    // deactivate the simple_model to start. this assigns
    // the component to the idle domain which effectively
    // disconnects it from the run phases in the uvm domain
    //------------------------------------------------------
    svunit_deactivate_uvm_component(my_simple_model);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();

    //---------------------------------------------------
    // activate the component (i.e. add the component to
    // the default uvm_domain)
    //---------------------------------------------------
    svunit_activate_uvm_component(my_simple_model);


    //--------------------------------------------------
    // UPDATE: the svunit_uvm_test invocation that used
    //      to be here has been moved up into the
    //      simple_model_unit_test *module*
    //--------------------------------------------------

    //-----------------------------
    // start the testing phase
    //-----------------------------
    svunit_uvm_test_start();
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();

    //-----------------------------
    // terminate the testing phase
    //-----------------------------
    svunit_uvm_test_finish();

    //-----------------------
    // flush the output fifo
    //-----------------------
    #0 out_fifo.flush();

    //----------------------------------------------------------
    // deactivate the component so that it doesn't interfere
    // with subsequent unit tests (i.e. reassign it to the idle
    // domain)
    //----------------------------------------------------------
    svunit_deactivate_uvm_component(my_simple_model);
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN


  //************************************************************
  // Test:
  //   get_port_not_null_test
  //
  // Desc:
  //   test for the existance of the simple_model::get_port
  //************************************************************
  `SVTEST(get_port_not_null_test)

    `FAIL_IF(my_simple_model.get_port == null);

  `SVTEST_END



  //************************************************************
  // Test:
  //   get_port_active_test
  //
  // Desc:
  //   ensure that objects put to the input are consumed once
  //   the component is started
  //************************************************************
  `SVTEST(get_port_active_test)
    begin
      simple_xaction tr = new();
 
      put_port.put(tr);
      #1;
      `FAIL_IF(!in_fifo.is_empty());
    end
  `SVTEST_END
 
 
 
  //************************************************************
  // Test:
  //   put_port_active_test
  //
  // Desc:
  //   ensure that objects put to the input are consumed and
  //   sent out on the get_port
  //************************************************************
  `SVTEST(put_port_active_test)
    begin
      time put_time;
      simple_xaction tr = new();
 
      put_time = $time;
      put_port.put(tr);
      get_port.get(tr);
      `FAIL_IF(put_time != $time);
    end
  `SVTEST_END
 
 
 
  //************************************************************
  // Test:
  //   xformation_test
  //
  // Desc:
  //   ensure that objects going through the simple model have
  //   their field property updated appropriately (multiply by
  //   2)
  //************************************************************
  `SVTEST(xformation_test)
    begin
      simple_xaction in_tr = new();
      simple_xaction out_tr;
 
      void'(in_tr.randomize() with { field == 2; });
 
      put_port.put(in_tr);
      get_port.get(out_tr);
 
      `FAIL_IF(in_tr.field != 2);
      `FAIL_IF(out_tr.field != 4);
    end
  `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
