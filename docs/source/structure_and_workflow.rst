Structure and Workflow
======================

The most basic SVUnit arrangement includes a single unit test template with 1 or more unit tests against a single UUT.

.. image:: ../user_guide_files/Screen-Shot-2015-07-03-at-3.23.35-PM.png
    :width: 477

A more likely arrangement is to have several unit test templates in a single directory, each containing unit tests for one of several UUTs. As examples, a design engineer building a subsystem with N modules would have N unit test templates running within a single test suite. Likewise, a verification engineer building a testbench with N transactors would also have N unit test templates running within a single test suite.

.. image:: ../user_guide_files/Screen-Shot-2015-07-03-at-3.23.44-PM.png
    :width: 476

A final, large scale arrangement is one with a test suite for each of M subsystems where each subsystem contains any number of unit test templates and the unit test templates for each subsystem are located in different directories.

.. image:: ../user_guide_files/Screen-Shot-2015-07-03-at-3.23.52-PM.png
    :width: 640

Hierarchy is derived from file/directory structure where all unit test templates located within the same directory are grouped into a test suite.
