`ifndef SVUNIT_UVM_MOCK_PKG
`define SVUNIT_UVM_MOCK_PKG

package svunit_uvm_mock_pkg;
  import uvm_pkg::*;
  import svunit_pkg::*;

  `include "uvm_macros.svh"

  `include "svunit_idle_uvm_domain.sv"
  `include "svunit_uvm_report_mock_types.svh"
  `include "svunit_uvm_report_mock.sv"
  `include "svunit_uvm_test.sv"
endpackage

`endif
