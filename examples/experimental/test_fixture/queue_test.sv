package queue_test;

  `include "svunit.svh"
  `include "svunit_defines.svh"

  import queue::*;


  virtual class queue_test extends svunit::test;

    protected queue #(int) q0;
    protected queue #(int) q1;
    protected queue #(int) q2;


    protected virtual function void set_up();
      q1.enqueue(1);
      q2.enqueue(2);
      q2.enqueue(3);
    endfunction

  endclass


  `TEST_F_BEGIN(queue_test, is_empty_initially)
    `FAIL_UNLESS_EQUAL(q0.size(), 0)
  `TEST_F_END

endpackage
