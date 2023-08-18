Special Considerations for Unit Testing UVM Components
======================================================

UVM components require additional infrastructure found in the svunit_uvm_mock_pkg. An additional switch, therefore, is included with create_unit_test.pl to generate a UVM component specific test case template. If, for example, class blah is derived from uvm_component, create_unit_test.pl would be invoked as::

    create_unit_test.pl -uvm -class_name blah

The UVM component test case template includes a UUT wrapper that can be used to instantiate any additional unit test infrastructure, like connections to TLM FIFOs or analysis ports, if required. The UUT wrapper in the test case template is output as::

    class blah_uvm_wrapper extends blah;
    
      `uvm_component_utils(blah_uvm_wrapper)
      function new(string name = "blah_uvm_wrapper", uvm_component parent);
        super.new(name, parent);
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
      endfunction
    endclass


The template also includes calls to functions svunit_activate_uvm_component, svunit_deactivate_uvm_component, svunit_uvm_test_start and svunit_uvm_test_finish in the build, setup and teardown tasks to integrate the UVM runflow with the sequential test running behaviour of SVUnit::

   //===================================
   // Build
   //===================================
   function void build();
      svunit_ut = new(name);

      my_blah = blah_uvm_wrapper::type_id::create("", null);

      svunit_deactivate_uvm_component(my_blah);
   endfunction


   //===================================
   // Setup for running the Unit Tests
   //===================================
   task setup();
      svunit_ut.setup();
      /* Place Setup Code Here */

      svunit_activate_uvm_component(my_blah);

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

      svunit_deactivate_uvm_component(my_blah);
   endtask


The activate/deactivate functions are used to isolate the component in the uvm_domain such that multiple uvm_components can be tested in series. The start/finish functions are used to invoke phase jumping such that unit tests against against a component can be run iteratively.
