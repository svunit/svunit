`define APB_ADDR_WIDTH 32
`define APB_DATA_WIDTH 32

interface apb_if (input clk);
  logic [`APB_ADDR_WIDTH-1:0] paddr;
  logic pwrite;
  logic psel;
  logic penable;
  logic [`APB_DATA_WIDTH-1:0] pwdata;
endinterface
