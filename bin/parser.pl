#!/usr/bin/perl

######################################################################
# Library Requirements
######################################################################
use strict;
use warnings;
use FileHandle;
#use POSIX qw(strftime);
use File::Basename;
use Errno qw(EAGAIN);

my $perl_script = "parser.pl";

######################################################################
# Sub-routines
######################################################################
#
# Show the usage summary
sub PrintUsage {
  print STDOUT <<"EOF";

  Usage: ${perl_script} <options> <filename>
  This script will parse the specified file for functions matching the qualifiers

  <options>
  -f                    search for functions  (can be used with -t)
  -t                    search for tasks      (can be used with -f)
  -v                    verbose; print matching functions
    -vc                 idem, without hash details
  -g                    generate the test double file
  -q <qualifiers> --    function qualifiers to search for

  <filename>            name of the file

  example:
    ${perl_script} -f -q virtual static -- uvm_object.svh           match virtual or static functions
    ${perl_script} -f -q "extern virtual" -- uvm_object.svh         match "extern virtual" functions
    ${perl_script} -f -q "extern virtual" static -- uvm_object.svh  match "extern virtual" or static functions
    ${perl_script} -f -t -q extern -- uvm_object.svh                match extern functions or tasks

EOF
  exit(1);
};

#
# Print the items
# in : ($rf,        reference to the hash of hashes as defined in ExtractItems()
#       $clean)     indicates to hide the hash details
sub PrintItems {
  my ($rf, $clean) = @_;
  if((exists $rf->{class}) && ($clean ne 1)) {
    #if($clean ne 1) {print "class[";}
    #print $rf->{class};
    #if($clean ne 1) {print "] ";}
    print "class[" . $rf->{class} . "] ";
  }
  if(exists $rf->{group}) {
    if($clean ne 1) {print "group[";}
    print $rf->{group};
    if($clean ne 1) {print "] ";}
  }
  if($clean eq 1) {print " ";}
  if(exists $rf->{quals}) {
    if($clean ne 1) {print "qualifiers[";}
    print $rf->{quals};
    if($clean ne 1) {print "] ";}
  }
  if($clean eq 1) {print " ";}
  if(exists $rf->{rtype}) {
    if($clean ne 1) {print "returned type[";}
    print $rf->{rtype};
    if($clean ne 1) {print "] ";}
  }
  if($clean eq 1) {print " ";}
  if(exists $rf->{name}) {
    if($clean ne 1) {print "name[";}
    print $rf->{name};
    if($clean ne 1) {print "] ";}
  }
  if(exists $rf->{args}) {
    if($clean ne 1) {print "arguments[";} else {print "(";}
    print $rf->{args};
    if($clean ne 1) {print "]";} else {print ")";}
  }
  print "\n";
}

#
# Remove extra spaces and/or newlines between each string items 
# in : ($string)
# out: ($string)
sub CleanStringItems {
  my ($string) = @_;
  chomp($string);
  my @split_string = split(' ',$string);
  chomp(@split_string);
  return $string = join(' ',@split_string);
}

sub ExtractFunctionArguments {
  my ($function_args) = @_;
  # split the arguments (comma separated)
  my @args = split(',', $function_args);
  my @args_inst;
  # find each argument instance name
  foreach my $arg (@args) {
    # split at the default value boundary, if any
    my @items = split('=',$arg);
    # remove the default value, if any
    pop(@items) if(scalar @items > 1);
    # split again at the word boundary
    @items = split(' ',@items);
    # keep only the instance name, i.e. last element
    push @args_inst, $items[$#items];
  }
  return \@args_inst;
}

#
# Extract the items of a group (function/task)
#
# Function
# |<- qualifiers                                           ->|
# [extern] [[pure] virtual] [automatic|static|protected|local] function [<rtype>] <name> [([args])];
#
# Task
# |<- qualifiers                                           ->|
# [extern] [[pure] virtual] [automatic|static|protected|local] task <name> [([args])];
#
# hash of hashes structure
#
# %items = (
#   {
#     class => "<class>",   # class scope (filled by ExtractGroups)
#     group => "<group>",   # function/task
#     quals => "<quals>",   # qualifiers as shown above
#     rtype => "<rtype>",   # returned type
#     name  => "<name>",    # function/task identifier
#     args  => "<args>",    # string of arguments
#
#     *** future implementation ***
#     args  => [            # arguments
#       { type => "<type>", name => "<name>", default => "<default>" },
#       { type => "<type>", name => "<name>", default => "<default>" },
#     ],
#
#   },
# );
#
# in : ($targets,     groups to search for (function, task, function|task)
#       $prototype)   group prototype, can spread on multiple lines
# out: (\%items)      reference to the hash of hashes
#
sub ExtractItems {
  my ($targets, $prototype) = @_;
  my %items = ();
  if($prototype =~ /(.*)(${targets})\s*(new|[\w]*)\s*([\w]*)\s*\(([^\)]*)\);/sx) {
    $items{group} = $2;
    $items{quals} = CleanStringItems($1);
    $items{args}  = CleanStringItems($5);
    if($2 ne "new") {
      $items{rtype} = $3;
      $items{name}  = $4;
    } else {
      $items{rtype} = "";
      $items{name}  = $3;
    }
    #PrintItems(\%items, 0);
  }
  return \%items;
}

#
# Extract groups of interest
# in : ($filename,    file to parse
#       $targets,     groups to search for (function, task, function|task)
#       @qualifiers)  groups qualifiers to search for
# out: (\@group)      reference to an array of hash of hashes as defined by ExtractItems()
#                     Note: Because the hash of hashes are added to an array, they will be
#                           listed in this array in the same order as they were found
sub ExtractGroups {
  my ($filename, $targets, $qualifiers) = @_;
  open FH, '<', "${filename}" or die "Can't open ${filename} $!\n";
  my @groups = ();    # reference to an array of hash of hashes
  my @classes = ();   # array to keep track of the class scopes
  {
    local $/ = "";    # paragraph mode
    while(<FH>) {
      my $prototype = "";
      # split the paragraph into lines
      my @lines = split(/\n/,$_);
      LINE: for my $line (@lines) {
        next LINE if(/^\s*\/\//); # skip commented lines
        next LINE if(/.*::/);     # skip lines with class scope operator "::"
        # beginning of a class
        if($line =~ /^(\s|virtual)*class\s*([\w]*)/x) {
          push @classes, $2;
        # end of a class
        } elsif($line =~ /^\s*endclass/) {
          pop @classes;
        # content of a class
        } elsif(scalar @classes ne 0) {
          # use the flip-flop operator to identify the start/end of a group
          if(($line =~ /${qualifiers}\s*${targets}/ .. /\s*;/x) || ($prototype ne "")) {
            $prototype .= "$line\n";
            # end of a group
            if($line =~ /;/) {
              my $items = ExtractItems($targets, $prototype);
              # add the class scope of where this group was found
              $items->{class} = join('::', @classes);
              push @groups, $items;
              $prototype = "";
            }
          }
        }
      }
    }
  }
  close(FH);
  return \@groups;
}

#
# Generate a test double of a class using the specified functions
#
# TODO: Add support for nested classes
#
sub GenerateTestDouble {
  my ($class, $rgroups) = @_;
  my $class_name = "test_${class}_double";
  open(FH, '>', "${class_name}.sv") or die "Can't open ${class_name}.sv $!\n";
  print FH "`ifndef __" . uc(${class_name}) . "__\n";
  print FH "`define __" . uc(${class_name}) . "__\n";
  print FH "\n";
  print FH "import uvm_pkg::*;\n";
  print FH "`include \"uvm_macros.svh\"\n";
  print FH "\n";
  print FH "class ${class_name} extends ${class};\n";
  foreach my $rhgroup (@$rgroups) {
    print FH "  bit " . ${rhgroup}->{name} . "_called = 0;\n";
  }
  print FH "\n";
  # find if the new function was captured
  foreach my $rhgroup (@$rgroups) {
    if(${rhgroup}->{name} eq "new") {
      print FH "  function new(" . ${rhgroup}->{args} . ");\n";
      my $rargs_inst = ExtractFunctionArguments(${rhgroup}->{args});
      print FH "    super.new(";
      foreach my $arg (@$rargs_inst) {
        print FH "$arg";
      }
      print FH "\n";
    }
  }
  foreach my $rhgroup (@$rgroups) {
    # test if the keys exists !!! or the error is from the function extraction
    print FH "  " . ${rhgroup}->{group} . " ". ${rhgroup}->{rtype} . " " . ${rhgroup}->{name} . "(" . ${rhgroup}->{args} . ");\n";
    print FH "    " . ${rhgroup}->{name} . "_called = 1;\n";
    my $rtype = ${rhgroup}->{rtype};
    my $rt = "";
    if($rtype ne "" && $rtype ne "void") {
      if($rtype =~ /byte|shortint|int|longint|integer|time/) {
        $rt = "0";
      } elsif($rtype =~ /bit|logic|reg/) {
        $rt = "'0";
      } elsif($rtype =~ /shortreal|real|realtime/) {
        $rt = "0.0";
      } elsif($rtype eq "string") {
        $rt = "\"\"";
      } else {
        $rt = "null";
      }
      print FH "    return ${rt};\n";
    }
    print FH "  end" . ${rhgroup}->{group} . "\n\n";
  }
  print FH "endclass\n";
  print FH "\n";
  print FH "`endif";
  close(FH);
}


######################################################################
# Main
######################################################################
STDOUT->autoflush(1);

my $verbose       = 0;
my $verbose_clean = 0;
my $gen_test_dbl  = 0;
my $target_function = 0;
my $target_task   = 0;
my @targs;
my @quals;
my $targets       = "";
my $qualifiers    = "";
my $filename      = "";

if(scalar @ARGV > 0) {
  while($_ = shift(@ARGV)) {
    if(/--help/) {
      PrintUsage();
      exit(1);
    } elsif(/-vc/) {
      $verbose = 1;
      $verbose_clean = 1;
    } elsif(/-v/) {
      $verbose = 1;
    } elsif(/-d/) {
      $gen_test_dbl = 1;
    } elsif(/-f/) {
      if($target_function eq 0) {
        $target_function = 1;
        push @targs, "function";
      } else {
        die "$_ declared more than once!\n";
      }
    } elsif(/-t/) {
      if($target_task eq 0) {
        $target_task = 1;
        push @targs, "task";
      } else {
        die "$_ declared more than once!\n";
      }
    } elsif(/-q/) {
      while($_ = $ARGV[0]) {
        if(/[^-]/) {
          push @quals, $_;
          shift(@ARGV);
        } elsif (/--/) {
          shift(@ARGV);
          last;
        } else {
          last;
        }
      }
    } elsif($filename eq "") {
      $filename = $_;
    }
  }
} else {
  PrintUsage();
  exit(1);
}

# sanity checking on the arguments
if(scalar @targs ne 0) {
  $targets = join('|',@targs);
}
if(scalar @quals ne 0) {
  $qualifiers = join('|',@quals);
}

#print "targets:     ${targets}\n";
#foreach(@targs) {
#  print "$_\n";
#}
#print "qualifiers:  ${qualifiers}\n";
#foreach(@quals) {
#  print "$_\n";
#}
#print "$filename\n";
#exit(1);

my $rgroups = ExtractGroups($filename, $targets, $qualifiers);

print "Found " . scalar @$rgroups . " \"${targets}\" matching qualifiers: ${qualifiers}\n";
if($verbose eq 1) {
  my $first_done = 0;
  foreach my $rhgroup (@$rgroups) {
    if($first_done eq 0) {
      $first_done = 1;
      print $rhgroup->{class} . "\n";
    }
    PrintItems(\%$rhgroup, $verbose_clean);
  }
}

if($gen_test_dbl eq 1) {
  my $class = "";
  my @split_filename = split('/',$filename);
  $class = $split_filename[$#split_filename];
  if($class =~ /(.*)\./) {
    $class = $1;
  }
  GenerateTestDouble($class, \@$rgroups);
}

