`define JUNK \
static string s = `"`FIDDLE_FADDLE`"; \
$display(s);

module dut;
initial begin
`JUNK
`ifdef DIDLEY_SQUAT
  $display("defined DIDLEY_SQUAT");
`endif
end
endmodule
