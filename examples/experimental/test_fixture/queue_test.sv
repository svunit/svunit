package queue_test;

  `include "svunit.svh"
  `include "svunit_defines.svh"

  import queue::*;


  class queue_test;  // TODO Extends from class for test fixture

    protected queue #(int) q0;
    protected queue #(int) q1;
    protected queue #(int) q2;


    protected virtual function void set_up();
      q1.enqueue(1);
      q2.enqueue(2);
      q2.enqueue(3);
    endfunction

  endclass


  `TEST_BEGIN(dummy_test_needed_because_otherwise_test_registration_crashes_and_burns)
  `TEST_END

endpackage
