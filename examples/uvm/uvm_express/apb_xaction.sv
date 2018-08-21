`ifndef __APB_XACTION_SV__
`define __APB_XACTION_SV__

`include "uvm_macros.svh"

import uvm_pkg::*;

class apb_xaction extends uvm_sequence_item;
  static const logic READ  = 0;
  static const logic WRITE = 1;
 
  rand logic        kind;
  rand logic [31:0] addr;
  rand logic [31:0] data;

  `uvm_object_utils_begin(apb_xaction)
    `uvm_field_int(kind, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_xaction");
     super.new(name);
  endfunction
endclass

`endif
