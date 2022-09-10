package queue;

  class queue #(type T = int);

    local T q_[$];


    function void enqueue(T e);
      q_.push_back(e);
    endfunction


    function T dequeue();
      return q_.pop_front();
    endfunction


    function int unsigned size();
      return q_.size();
    endfunction

  endclass

endpackage
