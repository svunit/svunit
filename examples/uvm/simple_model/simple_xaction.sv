`ifndef __SIMPLE_XACTION_SV__
`define __SIMPLE_XACTION_SV__

`include "uvm_macros.svh"

import uvm_pkg::*;

class simple_xaction extends uvm_sequence_item;
  rand int field;

  `uvm_object_utils_begin(simple_xaction)
    `uvm_field_int(field, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "simple_xaction");
     super.new(name);
  endfunction
endclass

`endif
