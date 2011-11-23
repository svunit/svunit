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


##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################
sub PrintHelp() {
  print "\n";
  print "Usage:  create_svunit.pl [ -help | -i | -no_ut | -r | -author \"name\" | -overwrite | -top ]\n\n";
  print "Where -help           : prints this help screen\n";
  print "      -no_ut          : does not create unit tests, only test suites and test runner\n";
  print "      -author \"Name\"  : specifies the author of this unit test file\n";
  print "      -overwrite      : overwrites the output file if it already exists\n";
  print "      -top            : creates the svunit_top.sv file\n";
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
      elsif ( @ARGV[$i] =~ /-no_ut/ ) {
        $no_ut = 1;
      }
      elsif ( @ARGV[$i] =~ /-author/ ) {
        $i++;
        $skip = 1;
        $author = $ARGV[$i];
      }
      elsif ( @ARGV[$i] =~ /-overwrite/ ) {
        $overwrite = "-overwrite";
      }
    }
  }
  if ( $author ne "" ) {
    $author = "-author \"" . $author . "\""; 
  }
  print "\n===============================\n";
  print "SVUNIT: Creating SVUNIT Framework:\n";
  print "===============================\n";
}

  
##########################################################################
# GetListDirs(): Gets the list of directories
##########################################################################
sub GetListDirs() {
  @dirs = `ls -l | grep ^dr | awk \'{print \$9}\'`;
  if ( $#dirs >= 0 ) {
    print "\nSVUNIT: Directories to create test suites against:\n";
    foreach $item ( @dirs ) {
      chomp( $item );
      print "          $item\n";
    }
  }
}


##########################################################################
# CreateUnitTests(): This task creates all the unit tests
##########################################################################
sub CreateUnitTests() {
  print "\n===============================\n";
  print "SVUNIT: Creating Unit Tests:\n";
  print "===============================\n";

  @files = `ls | grep \.sv | grep -v svn | grep -v pkg | grep -v testsuite | grep -v testrunner | grep -v unit_test`;
  foreach $i (@files) {
    $rc = system("$script_dir/create_unit_test.pl $author $overwrite $i");
    if ( $rc != 0 ) {
      die ("ERROR: create_unit_test.pl failed for $i.  Exiting\n\n");
    }
  }
}


##########################################################################
# WriteTopLevel(): Creates Top Level Module
##########################################################################
sub WriteTopLevel() {
  open ( TOPFILE, ">svunit_top.sv" ) or die "Error: Cannot Open File svunit_top.sv\n\n";

  print "\nSVUNIT: Creating top level file svunit_top.sv\n\n";

  print TOPFILE "\nmodule top;\n\n";
  print TOPFILE "  testrunner runner();\n\n";
  print TOPFILE "  initial\n  begin\n    runner.setup();\n    runner.run();\n    \$finish();\n  end\n\n";
  print TOPFILE "endmodule\n\n";

  close ( TOPFILE ) or die "ERROR: Cannot Close File svunit_top.sv\n\n";
}


##########################################################################
# This is the main run flow of the script
##########################################################################
CheckArgs();
WriteTopLevel();
