class equals_helper #(type T = int);

  task check(string lhs_expr, string rhs_expr, T lhs, T rhs, string file, int unsigned line);
    string original_expression = $sformatf("(%s) !== (%s)", lhs_expr, rhs_expr);
    string expanded_expression = $sformatf("(%p) !== (%p)", lhs, rhs);
    string message = $sformatf("%s, because %s", original_expression, expanded_expression);
    if (svunit_pkg::current_tc.fail("assert_eq", ((lhs) !== (rhs)), message, file, line)) begin
      if (svunit_pkg::current_tc.is_running()) svunit_pkg::current_tc.give_up();
    end
  endtask

endclass
