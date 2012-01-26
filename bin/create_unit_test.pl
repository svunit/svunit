#!/usr/bin/perl

################################################################
#
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#  
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
#
################################################################

require "$ENV{SVUNIT_INSTALL}/bin/create_test_globals.pl";

use File::Basename;


##########################################################################
# Local Variables
##########################################################################
$num_tests   = 0;
$total_tests = 0;


##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################
sub PrintHelp() {
  print "\n";
  print "Usage:  create_unit_test.pl [ -help | -out <file> | -i | -author \"Author\" | -overwrite | <testname> ]\n\n";
  print "Where -help          : prints this help screen\n";
  print "      -out <file>    : specifies a new default output file\n";
  print "      -author \"Name\" : specifies the author of this unit test file\n";
  print "      -overwrite      : overwrites the output file if it already exists\n";
  print "      <testname>     : the name of the testcase to run\n";
  print "\n";
  die;
}


##########################################################################
# CheckArgs(): Checks the arguments of the program.
##########################################################################
sub CheckArgs() {
  $numargs = @ARGV;

  for $i (0..$numargs-1) {
    if ( $skip == 1 ) {
      $skip = 0;
    }
    else {
      if ( @ARGV[$i] =~ /-help/ ) {
        PrintHelp();
      }
      elsif ( @ARGV[$i] =~ /-out/ ) {
        $i++;
        $skip = 1;
        $output_file = $ARGV[$i];
      }
      elsif ( @ARGV[$i] =~ /-author/ ) {
        $i++;
        $skip = 1;
        $author = $ARGV[$i];
      }
      elsif ( @ARGV[$i] =~ /-overwrite/ ) {
        $overwrite = 1;
      }
      else {
        if ( -r "@ARGV[$i]" ) {
          $testname = @ARGV[$i];
        }
      }
    }
  }
}

  
##########################################################################
# ValidArgs(): This checks to see if the arguments provided make sense.
##########################################################################
sub ValidArgs() {
  if ( $testname eq "" ) {
    print "\nERROR:  The testfile was either not specified, does not exist or is not readable\n";
    PrintHelp();
  }
  if ($output_file eq "") {
    $output_file = $testname;
    $output_file =~ s/.sv/_unit_test.sv/g;
  }
  else {
    ($base, $dir, $ext) = fileparse($output_file, qr/\.[^.]*/);
    if ($ext ne ".sv") {
      $output_file = $output_file . "\.sv";
    }
  }
}


##########################################################################
# OpenFiles(): This opens the input and output files
##########################################################################
sub OpenFiles() {
  open (INFILE,  "$testname")     or die "Cannot Open file $testname\n";
  if ( -r $output_file and $overwrite != 1 ) {
    print "\nERROR: The file already exists, to overwrite, use the -overwrite argument\n\n";
    exit 1;
  }
  else {
    open (OUTFILE, ">$output_file") or die "Cannot Open file $output_file\n";
  }
  open (HDRFILE, "$header_file")  or die "Cannot Open file $header_file\n";
}


##########################################################################
# CloseFiles(): This closes the input and output files
##########################################################################
sub CloseFiles() {
  close (INFILE)  or die "Cannot Close file $testname\n";
  close (OUTFILE) or die "Cannot Close file $output_file\n";
  #if ( $total_tests == 0 ) {
  #  system( "rm $output_file" );
  #}
  close (HDRFILE) or die "Cannot Close file $header_file\n";
}


##########################################################################
# GetTasksFunctions(): Gets the list of tasks and functions 
##########################################################################
sub GetTasksFunctions() {
  $incomments = 0;
  while ( $line = <INFILE> ) {
    # if a /* */ comment is still open, look for the end
    if ($incomments) {
      if ($line =~ m|.*\*/|) {
        $line =~ s|.*\*/||;
        $incomments = 0;
      }
    }

    if (!$incomments) {
      # filter // comments
      $line =~ s|//.*||;

      # filter full /* */ comments
      $line =~ s|/\*.*?\*/||g;
   
      # filter /* comments that go past the end of a line
      if ( $line =~ /\/\*/) {
        $line =~ s/\/\*.*//;
        $incomments = 1;
      }

      if ( $processing_uut == 0 ) {
        if ( $line =~ /^\s*class/ or $line =~ /^\s*virtual\s+class/ ) {
          $line =~ s/virtual//g;
          $line =~ s/^\s*class/class/g;
          $line =~ s/\s+/ /g;
          $line =~ s/\W/:/g;
          @items = split(/:/, $line);
          $uut = $items[1];
          $processing_class = 1;
          $processing_uut = 1;
        }
        elsif ( $line =~ /^\s*module/ or $line =~ /^\s*virtual\s+module/ ) {
          $line =~ s/^\s*module/module/g;
          $line =~ s/\s+/:/g;
          $line =~ s/\W/:/g;
          @items = split(/:/, $line);
          $uut = $items[1];
          $processing_module = 1;
          $processing_uut = 1;
        }
      }
      else {
        if ( $processing_class && $line =~ /^\s*endclass/ ) {
          CreateUnitTest();
          $total_tests = $total_tests + $num_tests;
          $num_tests = 0;
          @func_task = ();
          $processing_class = 0;
          $processing_uut = 0;
        }

        elsif ( $processing_module && $line =~ /^\s*endmodule/ ) {
          CreateUnitTest();
          $total_tests = $total_tests + $num_tests;
          $num_tests = 0;
          @func_task = ();
          $processing_module = 0;
          $processing_uut = 0;
        }

        ###########################################################################
        # below are the 2 branches that handle parsing of functions and task. These
        # aren't tested and I suspect they are pretty fragile.
        ###########################################################################
        elsif ( $line =~ /\s*function/ and $line !~ /endfunction/ and $line !~ /new/ and $line !~ /local/ and $line !~ /\/\/\s*function/ ) {
          if ( $line !~ /pure/ ) {
            $line =~ s/^\s*/ /g;         # This adds a space at the beginning so we know which item to choose
            $line =~ s/:/0/g;            # This is in case return type has ":" in it
            $line =~ s/extern//g;        # This removes the extern from the line if it exists
            $line =~ s/virtual//g;       # This removes the virtual from the line if it exists
            $line =~ s/\s+/:/g;          # This removes extra white spaces and replaces them with ":"
            $line =~ s/[\(;]/:/g;        # This turns the opening bracket of the argument list into a delimiter
            @items = split(/:/, $line);  # This splits the line into a list using the ":" as a delimiter
            $func = $items[3];           # For functions, the function name is now the 4th item in the list 
                                       # (the first is the start of line)
            push(@func_task,$func);      # Push the function name into a list of functions
          }
        }
        elsif ( $line =~ /\s*task/ and $line !~ /endtask/ and $line !~ /local/ and $line !~ /\/\/\s*task/ ) {
          if ( $line !~ /pure/ ) {
            $line =~ s/^\s*/ /g;
            #$line =~ s/^/ /g;
            $line =~ s/extern//g;
            $line =~ s/virtual//g;
            $line =~ s/\s+/:/g;
            $line =~ s/[\(;]/:/g;
            @items = split(/:/, $line);
            $tasks = $items[2];
            push(@func_task,$tasks);
          }
        }
      }
    }
  }
}


##########################################################################
# CreateUnitTest(): invoke the method to create a unit test for either a
#                   class or module
##########################################################################
sub CreateUnitTest() {
  if ($processing_class) {
    CreateClassUnitTest();
  }

  elsif ($processing_module) {
    CreateModuleUnitTest();
  }

  else {
    die "ERROR: CreateUnitTest called but \$processing_class or \$processing_module is asserted";
  }
}


##########################################################################
# CreateClassUnitTest(): This creates the output for the unit test class.  It's
#                   called for each class within the file
##########################################################################
sub CreateClassUnitTest() {
  $in_list = 0;

  print OUTFILE "`include \"svunit_defines.svh\"\n";
  print OUTFILE "`include \"" . basename($testname) . "\"\n";
  print OUTFILE "typedef class c_$uut\_unit_test;\n";
  print OUTFILE "\n";
  print OUTFILE "module $uut\_unit_test;\n";
  print OUTFILE "  c_$uut\_unit_test unittest;\n";
  print OUTFILE "  string name = \"$uut\_ut\";\n";
  print OUTFILE "\n";
  print OUTFILE "  function void setup();\n";
  print OUTFILE "    unittest = new(name);\n";
  print OUTFILE "  endfunction\n";
  print OUTFILE "endmodule\n";
  print OUTFILE "\n";
  print OUTFILE "class c_$uut\_unit_test extends svunit_testcase;\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // This is the class that we're \n";
  print OUTFILE "  // running the Unit Tests on\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  $uut my_$uut;\n\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Constructor\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  function new(string name);\n";
  print OUTFILE "    super.new(name);\n";
  print OUTFILE "  endfunction\n\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Setup for running the Unit Tests\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task setup();\n";
  print OUTFILE "    my_$uut = new(\/\* New arguments if needed \*\/);\n";
  print OUTFILE "    \/\* Place Setup Code Here \*\/\n  endtask\n\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // This is where we run all the Unit\n";
  print OUTFILE "  // Tests\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task run_test();\n";
  print OUTFILE "    super.run_test();\n";
  print OUTFILE "\n";

  foreach $func_item (@func_task) {
    foreach $excl_item (@exclude) {
      if ($excl_item eq $func_item) {
        $in_list = 1;
      }
    }
    if ($in_list == 0) {
      print OUTFILE "    test_$func_item();\n";
      push(@tests_to_run, $func_item);
      $num_tests++;
    }
    else {
      $in_list = 0;
    }
  }

  print OUTFILE "  endtask\n\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Here we deconstruct anything we \n";
  print OUTFILE "  // need after running the Unit Tests\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task teardown();\n";
  print OUTFILE "    super.teardown();\n";
  print OUTFILE "    \/\* Place Teardown Code Here \*\/\n";
  print OUTFILE "  endtask\n\n";


  print "\nSVUNIT: Output File: $output_file\n";
  print "\nSVUNIT: Creating class $uut\_unit_test with tasks/functions:\n\n";
  #if ( $#tests_to_run >= 0 ) {
  #  print "\nSVUNIT: Output File: $output_file\n";
  #  print "\nSVUNIT: Creating class $uut\_unit_test with tasks/functions:\n\n";
  #}
  #else {
  #  print "\nSVUNIT: $testname - $uut has no tasks/functions or none chosen.\n";
  #}
  
  foreach $test_item (@tests_to_run) {
    print OUTFILE "\n  //===================================\n";
    print OUTFILE "  // Unit test for task/function:\n";
    print OUTFILE "  //   $test_item\n";
    print OUTFILE "  //===================================\n";
    print OUTFILE "  task test_$test_item;\n";
    print OUTFILE "    `INFO(\$psprintf(\"Running %s\:\:test_$test_item\", name));\n";
    print OUTFILE "    \/\* Place Test Code Here \*\/\n  endtask\n\n";
    print "  $test_item\n";
  }

  print OUTFILE "endclass\n\n\n";
  @tests_to_run = ();
}


##########################################################################
# CreateModuleUnitTest(): This creates the output for the unit test class.  It's
#                   called for each module within the file
##########################################################################
sub CreateModuleUnitTest() {
  $in_list = 0;

  print OUTFILE "`include \"svunit_defines.svh\"\n";
  print OUTFILE "`include \"" . basename($testname) . "\"\n";
  print OUTFILE "typedef class c_$uut\_unit_test;\n";
  print OUTFILE "\n";
  print OUTFILE "module $uut\_unit_test;\n";
  print OUTFILE "  c_$uut\_unit_test unittest;\n";
  print OUTFILE "  string name = \"$uut\_ut\";\n";
  print OUTFILE "\n";
  print OUTFILE "  function void setup();\n";
  print OUTFILE "    unittest = new(name);\n";
  print OUTFILE "  endfunction\n";
  print OUTFILE "endmodule\n";
  print OUTFILE "\n";
  print OUTFILE "$uut my_$uut();\n";
  print OUTFILE "\n";
  print OUTFILE "class c_$uut\_unit_test extends svunit_testcase;\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Constructor\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  function new(string name);\n";
  print OUTFILE "    super.new(name);\n";
  print OUTFILE "  endfunction\n\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Setup for running the Unit Tests\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task setup();\n";
  print OUTFILE "    \/\* Place Setup Code Here \*\/\n  endtask\n\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // This is where we run all the Unit\n";
  print OUTFILE "  // Tests\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task run_test();\n";
  print OUTFILE "    super.run_test();\n";
  print OUTFILE "\n";
  print OUTFILE "  endtask\n\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Here we deconstruct anything we \n";
  print OUTFILE "  // need after running the Unit Tests\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task teardown();\n";
  print OUTFILE "    super.teardown();\n";
  print OUTFILE "    \/\* Place Teardown Code Here \*\/\n";
  print OUTFILE "  endtask\n\n";


  print "\nSVUNIT: Output File: $output_file\n";
  print "\nSVUNIT: Creating class $uut\_unit_test with tasks/functions:\n\n";
  
  foreach $test_item (@tests_to_run) {
    print OUTFILE "\n  //===================================\n";
    print OUTFILE "  // Unit test for task/function:\n";
    print OUTFILE "  //   $test_item\n";
    print OUTFILE "  //===================================\n";
    print OUTFILE "  task test_$test_item;\n";
    print OUTFILE "    `INFO(\$psprintf(\"Running %s\:\:test_$test_item\", name));\n";
    print OUTFILE "    \/\* Place Test Code Here \*\/\n  endtask\n\n";
    print "  $test_item\n";
  }

  print OUTFILE "endclass\n\n\n";
  @tests_to_run = ();
}


##########################################################################
# PrintHeading(): Prints out the XtremeEDA copyright heading
##########################################################################
sub PrintHeading() {
  while ( $line = <HDRFILE> ) {
    if ( $line =~ /FILENAME/ ) {
      $of = basename($output_file);
      $line =~ s/FILENAME/$of/g;
    }
    elsif ( $line =~ /DESCRIPTION/ ) {
      $tn = basename($testname);
      $line =~ s/DESCRIPTION/Unit Test file for $tn/g;
    }
    # NJ: rm this for now until we make it part of the unit test suite
    #elsif ( $line =~ /DATE/ ) {
    #  chomp( $date );
    #  $line =~ s/DATE/$date/g;
    #}
    #elsif ( $line =~ /AUTHOR/ ) {
    #  $line =~ s/AUTHOR/$author/g;
    #}
    print OUTFILE $line;
  }
  print OUTFILE "import svunit_pkg::\*;\n\n";
}


##########################################################################
# This is the main run flow of the script
##########################################################################
CheckArgs();
ValidArgs();
OpenFiles();
PrintHeading();
GetTasksFunctions();
CloseFiles(); 
