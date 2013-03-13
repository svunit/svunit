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

`ifndef __UUT_SV__
`define __UUT_SV__

class uut extends uvm_component;

  `uvm_component_utils(uut)

  function new(string name = "uut",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void verify_arg_is_not_99(bit [7:0] arg);
    if (arg == 99) `uvm_error("uut", "arg is 99!");
  endfunction

endclass

`endif
