package queue_test;

  `include "svunit.svh"
  `include "svunit_defines.svh"

  import queue::*;


  virtual class queue_test extends svunit::test;

    protected queue #(int) q0 = new();
    protected queue #(int) q1 = new();
    protected queue #(int) q2 = new();


    protected virtual function void set_up();
      q1.enqueue(1);
      q2.enqueue(2);
      q2.enqueue(3);
    endfunction

  endclass


  `TEST_F_BEGIN(queue_test, is_empty_initially)
    `FAIL_UNLESS_EQUAL(q0.size(), 0)
  `TEST_F_END


  `TEST_F_BEGIN(queue_test, dequeue_works)
    `FAIL_UNLESS_EQUAL(q1.dequeue(), 1)
    `FAIL_UNLESS_EQUAL(q1.size(), 0)

    `FAIL_UNLESS_EQUAL(q2.dequeue(), 2)
    `FAIL_UNLESS_EQUAL(q2.size(), 1)
  `TEST_F_END

endpackage
