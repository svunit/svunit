## Development using VS Code

Currently, VS Code has to be started from a shell
where SVUnit environment variables have been set up.
This is because the tests will try to call `runSVUnit` and other scripts,
and try to access the `SVUNIT_INSTALL` variable.


## Creating a new release

Steps:

- Ensure that the tests pass
  * See [test/README](test/README) for details on how to run the tests
- Determine the new `$VERSION` number based on semantic versioning and the information in [CHANGELOG.md](CHANGELOG.md)
- Create a new branch: `git checkout -b release-version-$VERSION`
- Update the version in [svunit_base/svunit_version_defines.svh](svunit_base/svunit_version_defines.svh)
- Update the version in [CHANGELOG.md](CHANGELOG.md)
  * Update the version and the date in the list
  * Update the link at the bottom, which points to the diff with the previous version
