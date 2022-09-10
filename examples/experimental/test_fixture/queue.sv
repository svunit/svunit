package queue;

  class queue #(type T = int);

    function void enqueue(T e);
    endfunction


    function int unsigned size();
    endfunction

  endclass

endpackage
