`ifndef __APB_BFM__
`define __APB_BFM__

`include "vmm.sv"
`include "amba_xaction.sv"

class apb_bfm extends vmm_xactor;

  // public members
  vmm_channel #(amba_xaction) cmd_inbox;

  function new(string name = "apb_bfm",
               string instance = "",
               int stream_id = -1,
               vmm_channel #(amba_xaction) cmd_inbox);
    super.new(name, instance, stream_id);

    if (cmd_inbox == null) this.cmd_inbox = new({ name , "::cmd_inbox" }, "");
  endfunction

endclass

`endif
