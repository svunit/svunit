# SVUnit

SVUnit is an open-source test framework for ASIC and FPGA developers writing Verilog/SystemVerilog
code. SVUnit is automated, fast, lightweight and easy to use making it the only SystemVerilog test
framework in existence suited to both design and verification engineers that aspire to high quality
code and low bug rates.

NOTE: for instructions on how to get going with SVUnit, go to
      www.agilesoc.com/svunit.

NOTE: Refer also to the FAQ at: www.agilesoc.com/svunit/svunit-FAQ


## Release Notes

Go [here](CHANGELOG.md) for release notes.


## Step-by-step instructions to get a first unit test going

### 1. Set up the `SVUNIT_INSTALL` and `PATH` environment variables

```shell
export SVUNIT_INSTALL=`pwd`
export PATH=$PATH:$SVUNIT_INSTALL"/bin"
```

You can source `Setup.bsh` if you use the bash shell.

```shell
source Setup.bsh
```

You can source `Setup.csh` if you use the csh shell.

```shell
source Setup.csh
```

### 2. Go somewhere outside `SVUNIT_INSTALL` (i.e. where you are right now)

Start a class-under-test:


    // file: bogus.sv
    class bogus;
    endclass

### 3. Generate the unit test

```shell
create_unit_test.pl bogus.sv
```

### 4. Add tests using the helper macros

    // file: bogus_unit_test.sv
    `SVUNIT_TESTS_BEGIN

      //===================================
      // Unit test: test_mytest
      //===================================
      `SVTEST(test_mytest)
      `SVTEST_END

    `SVUNIT_TESTS_END

### 5. Run the unit tests

```shell
runSVUnit -s <simulator> # simulator is ius, questa, modelsim, riviera or vcs
```

### 6. Repeat steps 4 and 5 until done

### 7. Pat self on back
