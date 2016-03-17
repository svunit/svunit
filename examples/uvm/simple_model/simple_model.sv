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

`ifndef __SIMPLE_MODEL_SV__
`define __SIMPLE_MODEL_SV__

`include "uvm_macros.svh"
`include "simple_xaction.sv"


//------------------------------------------------------
// A simple model that does minor data xformation of an
// object that appears on an input port, then sends the
// result to an output channel.
//------------------------------------------------------


class simple_model extends uvm_component;
  uvm_blocking_get_port #(simple_xaction) get_port;
  uvm_blocking_put_port #(simple_xaction) put_port;

  `uvm_component_utils(simple_model)

  function new(string name = "simple_model",
               uvm_component parent = null);
    super.new(name, parent);

    //------------------
    // new the get_port
    //------------------
    get_port = new("get_port", this);

    //------------------
    // new the put_port
    //------------------
    put_port = new("put_port", this);
  endfunction


  //----------------------------------------------------
  // transations that go through this simple model have
  // their field property multiplied by 2. that's it.
  //----------------------------------------------------
  task main_phase(uvm_phase phase);
    simple_xaction tr;
    uvm_domain d = get_domain();

    forever begin
      simple_xaction c;

      //------------------------------
      // get a xaction from the input
      //------------------------------
      get_port.get(tr);

      //----------------------------------------------------------
      // clone the input tr and do the simple data transformation
      //----------------------------------------------------------
      $cast(c, tr.clone());
      c.field = c.field * 2;

      //----------------------------
      // put xactions to the output
      //----------------------------
      put_port.put(c);
    end
  endtask
endclass

`endif
