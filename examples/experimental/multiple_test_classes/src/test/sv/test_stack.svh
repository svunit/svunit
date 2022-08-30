class test_stack;

  `TEST_BEGIN(new_stack_has_size_0)
    stack s = new();
    `FAIL_UNLESS_EQUAL(s.size(), 0)
  `TEST_END

endclass
