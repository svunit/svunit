`ifndef __APB_BFM__
`define __APB_BFM__

`include "vmm.sv"
`include "amba_xaction.sv"

class apb_mst extends vmm_xactor;

  // public members
  vmm_channel #(amba_xaction) cmd_inbox;
  virtual apb_if my_apb_if;

  function new(string name = "apb_mst",
               string instance = "",
               int stream_id = -1,
               vmm_channel #(amba_xaction) cmd_inbox,
               virtual apb_if my_apb_if);
    super.new(name, instance, stream_id);

    this.cmd_inbox = cmd_inbox;
    if (this.cmd_inbox == null) this.cmd_inbox = new({ name , "::cmd_inbox" }, "");

    this.my_apb_if = my_apb_if;
  endfunction

  extern virtual task main();
  extern virtual task bus_daemon();
  extern virtual function void reset_xactor(vmm_xactor::reset_e rst_typ = vmm_xactor::SOFT_RST);

endclass

task apb_mst::main();
  super.main();
  fork
    bus_daemon();
  join_none
endtask


task apb_mst::bus_daemon();
  forever begin
    vmm_data tr;
    amba_xaction amba_tr;

    cmd_inbox.get(tr);
    $cast(amba_tr, tr);

    //-------------------------------
    // transition from IDLE to SETUP
    //-------------------------------
    @(negedge my_apb_if.clk);
    my_apb_if.paddr  = amba_tr.addr;
    my_apb_if.pwrite = amba_tr.write;
    my_apb_if.psel   = 1;
    my_apb_if.penable = 0;
    my_apb_if.pwdata = amba_tr.data;

    //---------------------------------
    // transition from SETUP to ENABLE
    //---------------------------------
    @(negedge my_apb_if.clk);
    my_apb_if.penable   = 1;

    //----------------------------------------
    // transition from ENABLE to IDLE if
    // there are no xactions in the cmd_inbox
    //----------------------------------------
    tr = cmd_inbox.try_peek();
    if (tr == null) begin
      @(negedge my_apb_if.clk);
      my_apb_if.psel    = 0;
      my_apb_if.penable = 0;
    end

  end
endtask


function void apb_mst::reset_xactor(vmm_xactor::reset_e rst_typ);
  super.reset_xactor(rst_typ);

  my_apb_if.paddr   = 0;
  my_apb_if.pwrite  = 0;
  my_apb_if.psel    = 0;
  my_apb_if.penable = 0;
  my_apb_if.pwdata  = 0;
endfunction

`endif
