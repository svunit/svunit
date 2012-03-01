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

`ifndef __APB_COVERAGE_SV__
`define __APB_COVERAGE_SV__

`include "uvm_macros.svh"
`include "apb_xaction.sv"

import uvm_pkg::*;

class apb_coverage extends uvm_subscriber #(apb_xaction);
  `uvm_component_utils(apb_coverage)

  local apb_xaction sampled_obj;

  covergroup cg;
    addr_min_cp :
      coverpoint sampled_obj.addr {
        bins min = { 0 };
      }

    addr_max_cp :
      coverpoint sampled_obj.addr {
        bins max = { 'hffff_fffc };
      }

    addr_bins_cp :
      coverpoint sampled_obj.addr {
        bins b [16] = { [1:'hffff_fff8] };
      }

    data_min_cp :
      coverpoint sampled_obj.data {
        bins min = { 0 };
      }

    data_max_cp :
      coverpoint sampled_obj.data {
        bins max = { 'hffff_ffff };
      }

    data_bins_cp :
      coverpoint sampled_obj.data {
        bins b [32] = { [1:'hffff_fffe] };
      }
  endgroup;

  function new(string name = "apb_coverage",
               uvm_component parent = null);
    super.new(name, parent);

    cg = new();
  endfunction

  function void write(apb_xaction t);
    sampled_obj = t;

    cg.sample();
  endfunction

  function uvm_sequence_item get_sampled_obj();
    return sampled_obj;
  endfunction
endclass

`endif
