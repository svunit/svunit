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

`ifndef __APB_MON_SV__
`define __APB_MON_SV__

import uvm_pkg::*;
`include "apb_xaction.sv"

class apb_mon #(addrWidth = 8, dataWidth = 32) extends uvm_component;
  uvm_analysis_port #(apb_xaction) ap;
  virtual apb_if.passive_slv bfm;

  // xaction out
  local apb_xaction tr;

  // function args from the bfm
  local logic pwrite;
  local logic [addrWidth-1:0] paddr;
  local logic [dataWidth-1:0] pdata;

  function new(string name = "",
               uvm_component parent = null);
    super.new(name, parent);

    ap = new("ap", this);
  endfunction

  task main_phase(uvm_phase phase);
    forever begin
      tr = apb_xaction::type_id::create("tr");

      //---------------------------------
      // wait for a xaction from the bfm
      //---------------------------------
      bfm.capture(tr.kind, tr.addr, tr.data);
   
      //---------------------------
      // put the xaction to the ap
      //---------------------------
      ap.write(tr);
    end
  endtask
endclass

`endif
