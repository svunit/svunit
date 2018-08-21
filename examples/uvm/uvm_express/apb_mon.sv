`ifndef __APB_MON_SV__
`define __APB_MON_SV__

import uvm_pkg::*;
`include "apb_xaction.sv"

class apb_mon #(addrWidth = 8, dataWidth = 32) extends uvm_component;

  `uvm_component_utils(apb_mon)

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

  function void build_phase(uvm_phase phase);
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
