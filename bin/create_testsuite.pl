#!/usr/bin/env perl

############################################################################
#
#  Copyright 2011 The SVUnit Authors.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
############################################################################

##########################################################################
# Local Variables
##########################################################################
$num_tests   = 0;


##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################
sub PrintHelp() {
  print "\n";
  print "Usage:  create_testsuite.pl [ -help | -i | -r | -out <file> | -add <filename> | -overwrite ]\n\n";
  print "Where -help           : prints this help screen\n";
  print "      -out <file>     : specifies an output filename\n";
  print "      -add <filename> : adds test to test suite\n";
  print "      -overwrite      : overwrites the output file if it already exists\n";
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
      elsif ( @ARGV[$i] =~ /-add/ ) {
        $i++;
        $skip = 1;
        push(@files_to_add, $ARGV[$i]);
      }
      elsif ( @ARGV[$i] =~ /-inst/ ) {
        $i++;
        $skip = 1;
        push(@inst_to_add, $ARGV[$i]);
      }
      elsif ( @ARGV[$i] =~ /-overwrite/ ) {
        $overwrite = 1;
      }
    }
  }
}


##########################################################################
# ValidArgs(): This checks to see if the arguments provided make sense.
##########################################################################
sub ValidArgs() {
  if ( $output_file eq "" ) {
    print "ERROR:  The output file was not specified\n";
    PrintHelp();
  }
  if ( @files_to_add == 0 ) {
    print "ERROR:  No unit tests specified\n";
    PrintHelp();
  }
  print "SVUNIT: Output File: $output_file\n";
  $class = $output_file;
  $class =~ s/.*\///g;
  $class =~ s/\.sv//g;
  $class =~ s/\.//g;
}


##########################################################################
# OpenFiles(): This opens the input and output files
##########################################################################
sub OpenFiles() {
  if ( -r $output_file and $overwrite != 1 ) {
    print "ERROR: The file already exists, to overwrite, use the -overwrite argument\n\n";
    exit 1;
  }
  else {
    open ( OUTFILE, ">$output_file"  ) or die "Cannot Open file $output_file\n";
  }
}


##########################################################################
# CloseFiles(): This closes the input and output files
##########################################################################
sub CloseFiles() {
  close ( OUTFILE ) or die "Cannot Close file $output_file\n";
}

###############################################################################
# getUnitTests(@files_to_add): pull all the unit tests out of the files_to_add
###############################################################################
sub getUnitTests() {
  foreach $file (@files_to_add) {
    # open the file
    open ( UTFILE, "$file" ) or die "Cannot Open file $_\n";

    # remove the comments
    $incomments = 0;
    while ( <UTFILE> ) {
      # if a /* */ comment is still open, look for the end
      if ($incomments) {
        if (m|.*\*/|) {
          s|.*\*/||;
          $incomments = 0;
        }
      }

      if (!$incomments) {
        # filter // comments
        s|//.*||;

        # filter full /* */ comments
        s|/\*.*?\*/||g;

        # filter /* comments that go past the end of a line
        if (/\/\*/) {
          s/\/\*.*//;
          $incomments = 1;
        }

        # filter out the static/automatic keywords
        s/static//;
        s/automatic//;

        if ( /^\s*module\s*(\w+_unit_test);/ ) {
          push (@unittests, $1);
        }
      }
    }
  }
  return @unittests;
}


##########################################################################
# CreateTestSuite(): This creates the testsuite for all unit tests within
#                    this directory
##########################################################################
sub CreateTestSuite() {

  @unittests = getUnitTests();

  foreach ( @unittests ) {
    s/\.sv//g;
    $instance = $_;
    $instance =~ s/_unit_test/_ut/g;
    push( @class_names , $_ );
    push( @instance_names, $instance );
    $num_tests++;
  }

  foreach ( @inst_to_add ) {
    $instance = $_;
    $instance =~ s/_type_test/_tt/g;
    $instance =~ s/[#()"]/_/g;
    if ( $overwrite != 1) {
      print "\n";
    }
    push( @class_names , $_ );
    push( @instance_names, $instance );
    $num_tests++;
  }

  $cnt = 0;

  print "SVUNIT: Creating class $class:\n";

  print OUTFILE "module $class;\n";
  print OUTFILE "  import svunit_pkg::svunit_testsuite;\n\n";
  $inst = $class;
  $inst =~ s/_testsuite/_ts/g;
  print OUTFILE "  string name = \"$inst\";\n";
  print OUTFILE "  svunit_testsuite svunit_ts;\n";
  print OUTFILE "  \n";
  print OUTFILE "  \n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // These are the unit tests that we\n";
  print OUTFILE "  // want included in this testsuite\n";
  print OUTFILE "  //===================================\n";
  if ( $new != 1 ) {
    print "SVUNIT: Creating instances for:\n";
  }
  foreach ( @class_names ) {
    print OUTFILE "  $class_names[$cnt] $instance_names[$cnt]();\n";
    print "SVUNIT:    $class_names[$cnt]\n";
    $cnt++;
  }

  $cnt = 0;

  print OUTFILE "\n\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Build\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  function void build();\n";
  foreach $item ( @instance_names ) {
    print OUTFILE "    $item.build();\n";
    $cnt++;
  }

  $cnt = 0;

  print OUTFILE "    svunit_ts = new(name);\n";
  foreach $item ( @instance_names ) {
    print OUTFILE "    svunit_ts.add_testcase($item.svunit_ut);\n";
    $cnt++;
  }
  print OUTFILE "  endfunction\n\n";


  print OUTFILE "\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  // Run\n";
  print OUTFILE "  //===================================\n";
  print OUTFILE "  task run();\n";
  print OUTFILE "    svunit_ts.run();\n";
  foreach $item ( @instance_names ) {
    print OUTFILE "    $item.run();\n";
    $cnt++;
  }
  print OUTFILE "    svunit_ts.report();\n";
  print OUTFILE "  endtask\n\n";

  print OUTFILE "endmodule\n";

}


##########################################################################
# MoveFile(): This moves the overwrites the output file with the
#             temporary output file.
##########################################################################
sub MoveFile() {
  if ( -w $output_file ) {
    system("mv $output_file~ $output_file");
  }
  else {
    die "ERROR: Move from $output_file~ to $output_file failed";
  }
}


##########################################################################
# This is the main run flow of the script
##########################################################################
CheckArgs();
ValidArgs();
OpenFiles();
CreateTestSuite();
CloseFiles();
