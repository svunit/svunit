`include "defines.vh"

module rtl
#(
  width = `WIDTH
)
(
  input clk,
  input rst_n,
  input a,
  input b,
  output wire ab,
  output reg Qab
);

wire [width-1:0] a_wire;

my_and_module my_and_module(.a(a), .b(b), .ab(ab));

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    Qab <= 0;
  end else begin
    Qab <= ab;
  end
end

endmodule
