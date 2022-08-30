class test_queue;

  `TEST_BEGIN(new_queue_has_size_0)
    queue q = new();
    `FAIL_UNLESS_EQUAL(q.size(), 0)
  `TEST_END

endclass
