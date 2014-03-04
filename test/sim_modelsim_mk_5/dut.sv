module dut;
initial begin
  string dud;
  if (!$test$plusargs("JOKES")) $finish;
  $value$plusargs("DUD=%s", dud);
  if (dud != "busto") $finish;
end
endmodule
