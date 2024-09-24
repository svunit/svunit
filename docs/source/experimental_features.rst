Experimental Features
=====================

SVUnit provides a more streamlined way of defining tests,
which requires less boilerplate code.
This is an experimental feature,
which is still under development
and is not part of the public API.

To activate this feature,
use the `--enable-experimental` option of the `runSVUnit` script.

Here's an example of such a streamlined test:

.. literalinclude:: ../../examples/experimental/single_test_suite/factorial_test.sv
    :language: sv
