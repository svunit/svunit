`ifndef __DUD_SV___
`define __DUD_SV___

import uvm_pkg::*;

class basic extends uvm_component;

  function new(string name = "basic",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

`define REPORT_ACTUAL(TYPE) \
  function void actual_``TYPE(); \
    ```uvm_``TYPE("my_basic", `"TYPE message`"); \
  endfunction 

  `REPORT_ACTUAL(warning)
  `REPORT_ACTUAL(error)
  `REPORT_ACTUAL(fatal)

endclass

`endif
