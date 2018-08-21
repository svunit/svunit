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
