Special Considerations for Unit Testing UVM Components
======================================================

UVM components require additional infrastructure found in the svunit_uvm_mock_pkg. An additional switch, therefore, is included with create_unit_test.pl to generate a UVM component specific test case template. If, for example, class blah is derived from uvm_component, create_unit_test.pl would be invoked as::

    create_unit_test.pl -uvm -class_name blah

The UVM component test case template includes a UUT wrapper that can be used to instantiate any additional unit test infrastructure, like connections to TLM FIFOs or analysis ports, if required. The UUT wrapper in the test case template is output as:

.. image:: ../user_guide_files/Screen-Shot-2016-02-17-at-6.57.47-AM.png
    :width: 506

The template also includes calls to functions svunit_activate_uvm_component, svunit_deactivate_uvm_component, svunit_uvm_test_start and svunit_uvm_test_finish in the build, setup and teardown tasks to integrate the UVM runflow with the sequential test running behaviour of SVUnit.

.. image:: ../user_guide_files/Screen-Shot-2016-02-17-at-11.25.24-AM.png
    :width: 402

The activate/deactivate functions are used to isolate the component in the uvm_domain such that multiple uvm_components can be tested in series. The start/finish functions are used to invoke phase jumping such that unit tests against against a component can be run iteratively.
