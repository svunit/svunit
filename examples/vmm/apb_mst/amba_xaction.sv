`ifndef __AMBA_XACTION__
`define __AMBA_XACTION__

class amba_xaction extends vmm_data;
  // public members
  rand bit [`APB_ADDR_WIDTH-1:0] addr;
  rand bit write;
  rand bit [`APB_DATA_WIDTH-1:0] data;

  `vmm_data_member_begin(amba_xaction)
	  `vmm_data_member_scalar(addr, DO_ALL)
	  `vmm_data_member_scalar(write, DO_ALL)
	  `vmm_data_member_scalar(data, DO_ALL)
  `vmm_data_member_end(amba_xaction)
endclass


`endif
