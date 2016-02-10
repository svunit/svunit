`include "svunit_defines.svh"
`include "svunit_uvm_mock_pkg.sv"
`include "simple_model.sv"
import svunit_uvm_mock_pkg::*;

class simple_model_uvm_wrapper extends simple_model;

   `uvm_component_utils(simple_model_uvm_wrapper)

   // Add some extra ports and FIFOs in order to verify the simple_model wrapper's
   // connect_phase().
   uvm_blocking_put_port #(simple_xaction) in_put_port;
   uvm_tlm_fifo #(simple_xaction)          in_put_fifo;
   
   uvm_tlm_fifo #(simple_xaction)          out_get_fifo;
   uvm_blocking_get_port #(simple_xaction) out_get_port;
   
   function new(string name = "simple_model_uvm_wrapper", uvm_component parent);
      super.new(name, parent);
      in_put_port = new("in_put_port", null);
      in_put_fifo = new("in_put_fifo", null);
      out_get_fifo = new("out_get_fifo", null);
      out_get_port = new("out_get_port", null);
   endfunction

   //===================================
   // Build
   //===================================
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      /* Place Build Code Here */
      
   endfunction

   //==================================
   // Connect
   //=================================
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
      /* Place Connection Code Here */

      // Connect the extra ports/FIFOs to the simple_model ports.
      get_port.connect(in_put_fifo.get_export);
      in_put_port.connect(in_put_fifo.put_export);
      
      out_get_port.connect(out_get_fifo.get_export);
      put_port.connect(out_get_fifo.put_export);
   endfunction // connect_phase
   
endclass // simple_model_uvm_wrapper


module simple_model_unit_test;
   import svunit_pkg::svunit_testcase;

   string name = "simple_model_ut";
   svunit_testcase svunit_ut;


   //===================================
   // This is the UUT that we're 
   // running the Unit Tests on
   //===================================
   simple_model_uvm_wrapper my_simple_model;

   //-------------------------------------------
   // for testing purposes, add fifos and ports
   // to interact with the simple_model
   //-------------------------------------------

   //===================================
   // Build
   //===================================
   function void build();
      svunit_ut = new(name);

      my_simple_model = simple_model_uvm_wrapper::type_id::create("", null);

      if (my_simple_model == null) $display("Test model null.");

      svunit_deactivate_uvm_component(my_simple_model);
   endfunction


   //===================================
   // Setup for running the Unit Tests
   //===================================
   task setup();
      svunit_ut.setup();
      /* Place Setup Code Here */

      svunit_activate_uvm_component(my_simple_model);

      //-----------------------------
      // start the testing phase
      //-----------------------------
      svunit_uvm_test_start();
   endtask


   //===================================
   // Here we deconstruct anything we 
   // need after running the Unit Tests
   //===================================
   task teardown();
      svunit_ut.teardown();
      //-----------------------------
      // terminate the testing phase 
      //-----------------------------
      svunit_uvm_test_finish();

      /* Place Teardown Code Here */

      // After every test, flush the fifos so leftover FIFO contents doesn't affect
      // the next test.
      my_simple_model.out_get_fifo.flush();
      my_simple_model.in_put_fifo.flush();
      
      svunit_deactivate_uvm_component(my_simple_model);
   endtask


   //===================================
   // All tests are defined between the
   // SVUNIT_TESTS_BEGIN/END macros
   //
   // Each individual test must be
   // defined between `SVTEST(_NAME_)
   // `SVTEST_END
   //
   // i.e.
   //   `SVTEST(mytest)
   //     <test code>
   //   `SVTEST_END
   //===================================
   `SVUNIT_TESTS_BEGIN
     
     //************************************************************
     // Test:
     //   get_port_not_null_test
     //
     // Desc:
     //   test for the existance of the simple_model::get_port
     //************************************************************
     `SVTEST(get_port_not_null_test)

       `FAIL_IF(my_simple_model.get_port == null);

     `SVTEST_END


      //************************************************************
      // Test:
      //   get_port_active_test
      //
      // Desc:
      //   ensure that objects put to the input do not remain in the
      //   input FIFO.
      //************************************************************
     `SVTEST(get_in_port_active_test)
       begin
         simple_xaction tr = new();
 
         my_simple_model.in_put_port.put(tr);
         #1;
         `FAIL_UNLESS(my_simple_model.in_put_fifo.is_empty());
       end
     `SVTEST_END
 
      //************************************************************
      // Test:
      //   get_port_active_test
      //
      // Desc:
      //   ensure that objects put to the input move through the input
      //   FIFO to the output FIFO.
      //************************************************************
     `SVTEST(get_out_port_active_test)
       begin
         simple_xaction tr = new();
 
         my_simple_model.in_put_port.put(tr);
         #1;
         `uvm_info("simple_model_unit_test", $psprintf("out_get_fifo empty : %0d", my_simple_model.out_get_fifo.is_empty()), UVM_NONE)
         `FAIL_IF(my_simple_model.out_get_fifo.is_empty());
       end
     `SVTEST_END
 
     //************************************************************
     // Test:
     //   xformation_test
     //
     // Desc:
     //   ensure that objects going through the simple model have
     //   their field property updated appropriately (multiply by 2)
     //************************************************************
     `SVTEST(xformation_test)
       begin
         simple_xaction in_tr = new();
         simple_xaction out_tr;
      
         void'(in_tr.randomize() with { field == 2; });
         `FAIL_UNLESS(my_simple_model.out_get_fifo.is_empty());
      
         my_simple_model.in_put_port.put(in_tr);
         my_simple_model.out_get_port.get(out_tr);
      
         `FAIL_IF(in_tr.field != 2);
         `FAIL_IF(out_tr.field != 4);
       end
     `SVTEST_END
     
     `SVUNIT_TESTS_END

endmodule
