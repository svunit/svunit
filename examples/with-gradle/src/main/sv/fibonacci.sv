package fibonacci;

  function automatic int fibonacci(int n);
    if (n <= 1) begin
      return n;
    end else begin
      return fibonacci(n - 1) + fibonacci(n - 2);
    end
  endfunction

endpackage
