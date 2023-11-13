## Environment management

This project uses [direnv](https://direnv.net/) to manage its development environment.


## Development using VS Code

Currently, VS Code has to be started from a shell
where SVUnit environment variables have been set up.
This is because the tests will try to call `runSVUnit` and other scripts,
and try to access the `SVUNIT_INSTALL` variable.
