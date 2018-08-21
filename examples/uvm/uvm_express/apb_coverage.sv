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
        bins max = { 'hfc };
      }

    addr_bins_cp :
      coverpoint sampled_obj.addr {
        bins b [16] = { [1:'hf8] };
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

    kind_cp :
      coverpoint sampled_obj.kind;

    option.per_instance = 1;
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
