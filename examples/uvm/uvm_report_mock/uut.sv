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

  function void warn_arg_is_gt_100(bit [7:0] arg);
    if (arg > 100) uvm_report_warning("uut", "arg is gt 100!");
  endfunction

endclass

`endif
