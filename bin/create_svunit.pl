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

use strict;
use Cwd;
use IO::File;
use IO::Dir;


my $homeDir = getcwd;
my @unittest;
my $g_found_unit_test = 0;


##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################
sub PrintHelp() {
  print "\n";
  print "Usage:  create_svunit.pl [ -help ]\n\n";
  print "Where -help               : prints this help screen\n";
  print "\n";
  die;
}


sub CheckArgs() {
  my $numargs = @ARGV;

  for my $i (0..$numargs-1) {
    if ( my $skip == 1 ) {
      $skip = 0;
    }
    else {
      if ( @ARGV[$i] =~ /(-help)|(-h)/ ) {
        PrintHelp();
      }
    }
  }
}

#############################################
# sub processDir($)
#
# recursively go through the directory tree,
# collect all the unit tests and write the
# Makefiles
#############################################
sub processDir($$)
{
  my $dir = shift;
  my $root_test_dir = shift;
  my $DIR;
  my @incdir;
  my $handle;
  my @local_unittest;
  my @child;
  my $l_found_unit_test = 0;

  $DIR = IO::Dir->new($dir);

  while (defined($handle = $DIR->read))
  {
    # ignore hidden files
    if ($handle =~ /^\./)
    {}

    # if it's a unit test, push it to the list of tests for that dir
    elsif ($handle =~ /.*_unit_test\.sv$/)
    {
      push(@unittest, "$dir/$handle");
      push(@local_unittest, $handle);
      $g_found_unit_test = 1;
      $l_found_unit_test = 1;

      # add this dir to the incdir list if it hasn't already
      if (join(@incdir, ":") !~ "$dir")
      {
        push(@incdir, "$dir");
      }
    }

    # if it's a dir, process it
    elsif (-d "$dir/$handle")
    {
      push(@child, processDir("$dir/$handle", 0));
    }
  }

  # write the Makefile if there are tests in the local dir
  # or if this is the root dir and the g_found_unit_test has been set
  if ($root_test_dir && $g_found_unit_test ||
      $l_found_unit_test)
  {
    my $fh = IO::File->new();
    my $dirID = $dir;

    # convert any illegal verilog chars to a '_'
    $dirID =~ s/[\/\.-]/_/g;
    $dirID = "." . $dirID;

    print "Info: Writing $dir/Makefile\n";
    if ($fh->open(">$dir/Makefile"))
    {
      if (@unittest > 0) {
        # collect all the unit tests
        $fh->print("UNITTESTS +=");
        foreach my $ut (@unittest) { $fh->print(" $ut"); }
        $fh->print("\n\n");
      }
      if (@incdir > 0) {
        # mangle the INCDIRS
        $fh->print("INCDIR +=");
        foreach my $d (@incdir) { $fh->print(" $d"); }
        $fh->print("\n\n");
      }
      if (@child > 0)
      {
        # mangle the .TESTSUITES
        $fh->print(".TESTSUITES =");
        foreach my $c (@child) { $fh->print(" $c"); }
        $fh->print("\n\n");
      }
      if (@local_unittest > 0)
      {
        $fh->print("TESTSUITES = $dir/$dirID\_testsuite.sv\n");
        $fh->print("$dirID\_UNITTESTS = ");
        foreach my $local_unittest (@local_unittest)
        {
          $fh->print("$dir/$local_unittest ");
          push(@child, "$dir/$dirID\_testsuite.sv");
        }
      }
      $fh->print("\n\n-include svunit.mk\n");
      $fh->print("include \$(SVUNIT_INSTALL)/bin/cfg.mk\n");
      $fh->close;
    }

    else
    {
      dir $!;
    }
  }

  return @child;
}

CheckArgs();
processDir($homeDir, 1);

if ($g_found_unit_test)
{
  exit 0;
}

else
{
  print "Info: Found no unit tests. No SVUnit framework created.\n";
  exit 1;
}
