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
sub processDir
{
  my $dir = shift;
  my $root_test_dir = shift;
  my $r_parent_testsuites = shift;
  my $r_parent_incdir = shift;
  my $r_parent_unittest = shift;
  my $DIR;
  my @incdir;
  my @unittest;
  my $handle;
  my @child_unittest;
  my @child_testsuites;

  $DIR = IO::Dir->new($dir);

  while (defined($handle = $DIR->read))
  {
    # ignore hidden files
    if ($handle =~ /^\./)
    {}

    # if it's a unit test, push it to the list of tests for that dir
    elsif ($handle =~ /.*_unit_test\.sv$/)
    {
      push(@unittest, $handle);
      $g_found_unit_test = 1;

      # add this dir to the incdir list if it hasn't already
      if (join(@incdir, ":") !~ "$dir")
      {
        push(@incdir, "$dir");
      }
    }

    # if it's a dir, process it
    elsif (-d "$dir/$handle")
    {
      processDir("$dir/$handle", 0, \@child_testsuites, \@incdir, \@child_unittest);
    }
  }


  # pass my incdirs back to the parent
  push(@{$r_parent_incdir}, @incdir);
  push(@{$r_parent_unittest}, @child_unittest);
  push(@{$r_parent_testsuites}, @child_testsuites);


  # write the Makefile if there are tests in the local dir or
  # if there are child_testsuites
  if (@child_testsuites > 0 ||
      @unittest > 0)
  {
    my $fh = IO::File->new();
    my $dirID = $dir;

    # convert any illegal verilog chars to a '_'
    $dirID =~ s/[\/\.-]/_/g;
    $dirID = "." . $dirID;

    print "Info: Writing $dir/Makefile\n";
    if ($fh->open(">$dir/Makefile"))
    {
      if (@child_unittest > 0) {
        # collect all the unit tests
        $fh->print("CHILD_UNITTESTS +=");
        foreach my $ut (@child_unittest) { $fh->print(" $ut"); }
        $fh->print("\n\n");
      }
      if (@incdir > 0) {
        # mangle the INCDIRS
        $fh->print("INCDIR +=");
        foreach my $d (@incdir) { $fh->print(" $d"); }
        $fh->print("\n\n");
      }
      if (@child_testsuites > 0)
      {
        # mangle the CHILD_TESTSUITES
        $fh->print("CHILD_TESTSUITES =");
        foreach my $c (@child_testsuites) { $fh->print(" $c"); }
        $fh->print("\n\n");
      }
      if (@unittest > 0)
      {
        $fh->print("TESTSUITES = $dir/$dirID\_testsuite.sv\n");
        #$fh->print("$dirID\_UNITTESTS = ");
        $fh->print("UNITTESTS = ");
        foreach my $unittest (@unittest)
        {
          $fh->print("$dir/$unittest ");
          push(@{$r_parent_unittest}, "$dir/$unittest");
        }
        push(@{$r_parent_testsuites}, "$dir/$dirID\_testsuite.sv");
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
