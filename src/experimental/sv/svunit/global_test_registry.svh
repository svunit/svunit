/**
 * A wrapper over a @{link test_registry} object.
 *
 * Some simulators (for example QuestaSim) don't support references to package variables or
 * functions that have not been been declared yet. Forward typedefs solve this problem.
 */
class global_test_registry;

  local static test_registry inst;


  static function test_registry get();
    if (inst == null)
      inst = new();
    return inst;
  endfunction

endclass
