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
sub processDir($)
{
  my $dir = shift;
  my $DIR;
  my $handle;
  my @unittest;
  my @child;

  $DIR = IO::Dir->new($dir);

  while (defined($handle = $DIR->read))
  {
    # ignore hidden files
    if ($handle =~ /^\./)
    {}

    # if it's a unit test, push it to the list of tests for that dir
    elsif ($handle =~ /.*_unit_test.sv/)
    {
      push(@unittest, $handle);
    }

    # if it's a dir, process it
    elsif (-d "$dir/$handle")
    {
      push(@child, processDir("$dir/$handle"));
    }
  }

  # write the Makefile
  my $fh = IO::File->new();
  my $dirID = "." . $dir;
  $dirID =~ s/\//_/g;

  # convert any illegal verilog chars to a '_'
  $dirID =~ s/-/_/g;

  print "Info: Writing $dir/Makefile\n";
  if ($fh->open(">$dir/Makefile"))
  {
    if (@child > 0)
    {
      $fh->print(".TESTSUITES =");
      foreach my $c (@child) { $fh->print(" $c"); }
      $fh->print("\n");
    }
    if (@unittest > 0)
    {
      $fh->print("TESTSUITES = $dirID\_testsuite.sv\n");
      $fh->print("$dirID\_UNITTESTS = ");
      foreach my $unittest (@unittest)
      {
        $fh->print("$unittest ");
        push(@child, "$dir/$dirID\_testsuite.sv");
      }
    }
    $fh->print("\n-include svunit.mk\n");
    $fh->print("include \$(SVUNIT_INSTALL)/bin/cfg.mk\n");
    $fh->close;
  }

  else
  {
    dir $!;
  }

  return @child;
}

CheckArgs();
processDir($homeDir);
