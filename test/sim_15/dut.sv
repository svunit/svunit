module dut #(
    parameter int A = 0,
    parameter type T = int,
    parameter T V = '1
);

    function void print();
        $display("print from param dut %m");
        $display("  parameter A: %0d", A);
        $display("  parameter $bits(T): %0d", $bits(T));
        $display("  parameter V: %h", V);
    endfunction


endmodule
