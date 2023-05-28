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

use strict;
use Getopt::Long;
use File::Glob;
use File::Find;
use IO::File;
use Cwd 'abs_path';

use vars qw/ %opt /;

use constant {
    CMDLINE_USAGE_ERROR => 4,
    # TODO Add other error codes
};

##########################################################################
# PrintHelp(): Prints the script usage.
##########################################################################

my $cmd;
my $logfile = "run.log";
my $vlogfile = "compile.log";
my $simulator;
my @defines;
my @filelists;
my $uvm;
my $wavedrom;
my @directory;
my @simargs;
my @compileargs;
my $outdir = ".";
my $clean;
my $vhdlfile;
my @tests;
my $filter;
my $enable_experimental;
my $help;

sub usage () {
  print "Usage:  runSVUnit [-s|--sim <simulator> -l|--log <log> -d|--define <macro> -f|--filelist <file> -U|-uvm -m|-mixedsim <vhdlfile>\n";
  print "                  -r|--r_arg <option> -c|--c_arg <option> -o|--out <dir> -t|--test <test> --filter <filter>]\n";
  print "  -s|--sim <simulator>     : simulator is either of questa, modelsim, riviera, ius, xcelium, vcs, dsim, verilator\n";
  print "  -l|--log <log>           : simulation log file (default: run.log)\n";
  print "  -d|--define <macro>      : appended to the command line as +define+<macro>\n";
  print "  -f|--filelist <file>     : some verilog file list\n";
  print "  -r|--r_arg <option>      : specify additional runtime options\n";
  print "  -c|--c_arg <option>      : specify additional compile options\n";
  print "  -U|--uvm                 : run SVUnit with UVM\n";
  print "  -o|--out                 : output directory for tmp and simulation files\n";
  print "  -t|--test                : specifies a unit test to run (multiple can be given)\n";
  print "  -m|--mixedsim <vhdlfile> : consolidated file list with VHDL files and command line switches\n";
  print "  -w|--wavedrom            : process json files as wavedrom output\n";
  print "     --filter <filter>     : specify which tests to run, as <test_module>.<test_name>\n";
  print "     --directory           : only run svunit discovery on selected directories\n";
  print "     --enable-experimental : enable experimental features\n";
  print "  -h|--help                : prints this help screen\n";
  print "\n";
  exit 1;
}

sub clean () {
  find({
      wanted => sub {
                      if (/^\..*testsuite\.sv$/   or
                          /^\..*testrunner\.sv$/
                      ) {
                        unlink;
                      }
                    }
    }, $outdir);

  unlink qw( run.log .svunit.f vsim.wlf ncsc.log irun.key );
  system("rm -rf work INCA_libs");
}

# command line options
GetOptions("l|log=s" => \$logfile,
           "s|sim=s" => \$simulator,
           "d|define=s" => \@defines,
           "f|filelist=s" => \@filelists,
           "U|uvm" => \$uvm,
           "r|r_arg=s" => \@simargs,
           "c|c_arg=s" => \@compileargs,
           "o|out=s" => \$outdir,
           "m|mixedsim=s" => \$vhdlfile,
           "t|test=s{,}" => \@tests,
           "filter=s" => \$filter,
           "w|wavedrom" => \$wavedrom,
           "directory=s" => \@directory,
           "enable-experimental" => \$enable_experimental,
           "h|help" => \$help
           ) or usage();

usage() if $help;

foreach (@directory) {
    if (File::Spec->file_name_is_absolute($_)) {
        print("Argument error: absolute paths are not yet supported as values for '--directory'\n");
        exit CMDLINE_USAGE_ERROR;
    }
}

if ($simulator eq "verilator" && defined $uvm) {
    print("Argument error: cannot run Verilator with UVM\n");
    exit CMDLINE_USAGE_ERROR
}

if ($simulator eq "verilator" && defined $vhdlfile) {
    print("Argument error: cannot run Verilator with VHDL\n");
    exit CMDLINE_USAGE_ERROR
}

clean();

# version
my $VERSION = IO::File->new();
$VERSION->open("$ENV{SVUNIT_INSTALL}/VERSION.txt") || die;
my $version = $VERSION->getline;
chomp $version;
push @defines, "SVUNIT_VERSION=$version";

# Extract simulator from PATH if nothing passed as argument
if ($simulator eq "") {
  my @sims = qw(xrun irun qrun vsim vcs dsim verilator);
  foreach my $sim (@sims) {
    if (system("which $sim > /dev/null 2>&1") == 0) {
      $simulator = $sim;
      last;
    }
  }

  # We look for the executable 'vsim', but the script uses 'modelsim' as a simulator name
  $simulator =~ s/vsim/modelsim/;
}

# simulator check
$simulator =~ tr/A-Z/a-z/;
$simulator =~ s/questa/modelsim/;
$simulator =~ s/ius/irun/;
$simulator =~ s/xcelium/xrun/;

if (not grep { $_ eq $simulator } qw(xrun irun modelsim riviera vcs dsim qrun verilator)) {
  print("Could not determine simulator. None found on 'PATH' and none specified via command line\n");
  usage()
}

# start the command line
$cmd = "cd $outdir; ";
# add the vdhl switches if necessary
if ($simulator eq "modelsim" or $simulator eq "riviera") {
  $cmd .= "vlib work; ";
  $cmd .= "vcom -work work -f $vhdlfile ; " if $vhdlfile;
  $cmd .= "vlog -l $vlogfile ";
} elsif ($simulator eq "vcs") {
  $cmd .= "$simulator -R -sverilog -l $logfile";
  $cmd .= "-f $vhdlfile " if $vhdlfile;
} elsif ($simulator eq "verilator") {
  $cmd .= "verilator --binary --top-module testrunner";
  $cmd .= qq! @compileargs!;
} else {
  $cmd .= "$simulator -l $logfile ";
  $cmd .= "-f $vhdlfile " if $vhdlfile;
}

# add the uvm switches if necessary
if (defined $uvm) {
  $cmd .= " -uvm" if ($simulator eq "xrun" or $simulator eq "irun");
  $cmd .= " -ntb_opts uvm" if $simulator eq "vcs";
  $cmd .= ' +incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv -sv_lib $UVM_HOME/src/dpi/libuvm_dpi.so' if $simulator eq "dsim";
  push @defines, "RUN_SVUNIT_WITH_UVM";
}

# add the filelists and defines
foreach (@filelists) {
  my $f = abs_path($_);
  $cmd .= " -f " . join "  -f ", $f;
}
$cmd .= " -f .svunit.f";

# defines
$cmd .= " +define+" . join " +define+", @defines if (@defines > 0);

if ($simulator eq "modelsim" or $simulator eq "riviera") {
  if (!grep(/(^| )(-gui|-c|-i)( |$)/, @simargs)) {
    push @simargs, "-c";
  }
  $cmd .= qq! @compileargs; vsim @simargs -lib work -do "run -all; quit" -l $logfile testrunner!;
} elsif ($simulator eq "verilator") {
  my $verilator_simargs = "";
  $verilator_simargs .= " @simargs";
  if (defined $filter) {
    $verilator_simargs .= " +SVUNIT_FILTER=$filter";
  }
  $cmd .= qq! ; obj_dir/Vtestrunner $verilator_simargs 2>&1 | tee $logfile !;
} else {
  $cmd .= " @compileargs @simargs -top testrunner";
}

if (defined $filter && $simulator ne "verilator") {
  $cmd .= " +SVUNIT_FILTER=$filter";
}

my $build_cmd = "buildSVUnit -o $outdir";

foreach (@directory) {
    $build_cmd .= " --directory $_";
}

if ($enable_experimental) {
    $build_cmd .= " --enable-experimental";
}

foreach (@tests) {
  $build_cmd .= " -t $_";
}
$build_cmd .= " --uvm" if $uvm;
$build_cmd .= " --wavedrom" if $wavedrom;

# include mock package for UVM compilation
if (defined $uvm) {
  $build_cmd .= " --mock";
}

# run!!
if (system("$build_cmd")) {
  exit -1;
}
print $cmd . "\n";
system("$cmd");
system("svunit_user_feedback.pl")
