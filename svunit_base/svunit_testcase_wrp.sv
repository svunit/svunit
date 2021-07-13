
/**
 * Class: svunit_testcase_launcher
 *
 * Base class for launchers wrapper
 */
virtual class svunit_testcase_launcher;
  svunit_pkg::svunit_testcase ut;
  pure virtual function void wrp_build();
  pure virtual task wrp_setup();
  pure virtual task wrp_teardown();
  pure virtual task automatic wrp_run();
endclass


/**
 * Class: svunit_testcase_wrp
 *
 * Wrapper for testcases - wraps svunit_testcase methods with call on children
 */
class svunit_testcase_wrp extends svunit_pkg::svunit_testcase;
  svunit_testcase_launcher launcher[$];

  function new(string name);
    super.new(name);
  endfunction

  function void build();
    foreach(launcher[i]) begin
      svunit_pkg::current_tc = launcher[i].ut;
      launcher[i].wrp_build();
    end
  endfunction

  task automatic run();
    foreach(launcher[i]) begin
      launcher[i].wrp_run();
      launcher[i].ut.report();
      error_count += launcher[i].ut.get_error_count();
    end
    update_exit_status();
  endtask

  function void add_launcher_inst(svunit_testcase_launcher inst);
    launcher.push_back(inst);
  endfunction

endclass
