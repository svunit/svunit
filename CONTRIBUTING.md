## Development using VS Code

Currently, VS Code has to be started from a shell
where SVUnit environment variables have been set up.
This is because the tests will try to call `runSVUnit` and other scripts,
and try to access the `SVUNIT_INSTALL` variable.


## Creating a new release

Steps:

- Ensure that the tests pass
  * See [test/README](test/README) for details on how to run the tests
