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

`ifndef __APB_COVERAGE_AGENT_SV__
`define __APB_COVERAGE_AGENT_SV__

`include "uvm_macros.svh"

`include "apb_mon.sv"
`include "apb_coverage.sv"

import uvm_pkg::*;

class apb_coverage_agent extends uvm_agent;
  `uvm_component_utils(apb_coverage_agent)

  virtual apb_if.passive_slv bfm;

  apb_mon monitor;
  apb_coverage coverage;

  function new(string name = "apb_coverage_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if( !uvm_config_db#(virtual apb_if.passive_slv)::get(
        this, "", "bfm", bfm)) begin
      `uvm_fatal("ENV", "BFM not set")
    end

    monitor  = apb_mon#(8,32)::type_id::create({ get_name() , "::monitor" },  this);
    coverage = apb_coverage::type_id::create({ get_name() , "::coverage" }, this);
  endfunction

  function void connect_phase(uvm_phase phase);
    monitor.bfm = bfm;
    monitor.ap.connect(coverage.analysis_export);
  endfunction
endclass

`endif
