class client;
  local server s;

  function new(server s);
    this.s = s;
  endfunction

  function void do_something();
    // ...
    // Should call:
    //s.perform(server::ACTION0);
  endfunction

  function void do_something_else(bit is_cool);
    int value;
    // ...
    // Computes value wrong:
    value = is_cool ? 1000 : 0;
    // ...
    s.perform(server::ACTION1, value);
  endfunction
endclass
