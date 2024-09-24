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

.. code-block:: sv

    package factorial_test;

      import factorial::*;

      `include "svunit.svh"
      `include "svunit_defines.svh"


      `TEST_BEGIN(handles_zero_input)
        `FAIL_UNLESS(factorial(0) == 1)
      `TEST_END


      `TEST_BEGIN(handle_positive_input)
        `FAIL_UNLESS(factorial(1) == 1)
        `FAIL_UNLESS(factorial(2) == 2)
        `FAIL_UNLESS(factorial(3) == 6)
        `FAIL_UNLESS(factorial(8) == 40320)
      `TEST_END

    endpackage
