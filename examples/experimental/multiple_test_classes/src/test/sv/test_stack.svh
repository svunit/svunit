class test_stack;

  `TEST_BEGIN(new_stack_has_size_0)
    stack s = new();
    `FAIL_UNLESS_EQUAL(s.size(), 0)
  `TEST_END


  `TEST_BEGIN(push_increments_size)
    stack s = new();
    s.push(100);
    `FAIL_UNLESS_EQUAL(s.size(), 1)
  `TEST_END

endclass
