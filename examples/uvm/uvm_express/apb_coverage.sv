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

  function new(string name = "apb_coverage",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(apb_xaction t);
  endfunction
endclass

`endif
