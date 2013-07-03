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


######################################################################
# Library Requirements
######################################################################
use strict;
use warnings;
use FileHandle;
use File::Basename;
use Errno qw(EAGAIN);

######################################################################
# Global variables
######################################################################
my $perl_script = "parser.pl";
my $verbose     = 0;

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
    -c                    verbose clean; without hash details
  -g                    generate the test double file
  -q <qualifiers> --    function qualifiers to search for

  <filename>            name of the file

  example:
    ${perl_script} -f -q virtual static -- uvm_object.svh           match virtual or static functions
    ${perl_script} -f -q "extern virtual" -- uvm_object.svh         match exactly "extern virtual" functions
    ${perl_script} -f -q "extern virtual" static -- uvm_object.svh  match "extern virtual" or static functions
    ${perl_script} -ft -q extern -- uvm_object.svh                  match extern functions or tasks

  Notes:
    -Virtual classes are automatically included in the class search
    -If qualifier 'extern' is specified, search results will only include extern functions/tasks
    -If qualifier 'extern' is omitted, search results will include extern and non-extern functions/tasks

EOF
  exit(1);
};

#
# Print class items' content
# in : ($hr,                reference to a class items hash
#       $clean)             when set, indicates to hide the hash details
sub PrintClassItems {
  my ($hr, $clean) = @_;
  my $str = "";
  if(exists $hr->{quals}) {
    $str = $hr->{quals};
    if($clean) {print "$str ";}
    else       {print "quals[${str}] ";}
  }
  if(exists $hr->{group}) {
    $str = $hr->{group};
    if($clean) {print "$str ";}
    else       {print "group[${str}] ";}
  }
  if(exists $hr->{rtype}) {
    $str = $hr->{rtype};
    if($clean) {print "$str ";}
    else       {print "rtype[${str}] ";}
  }
  if(exists $hr->{name}) {
    $str = $hr->{name};
    if($clean) {print "$str ";}
    else       {print "name[${str}] ";}
  }
  if(exists $hr->{args}) {
    print "(";
    for my $i (0 .. $#{$hr->{args}}) {
      my $hr_arg = ${$hr->{args}}[$i];
      if($i > 0) {
        print ", ";
      }
      if($clean) {
        print $hr_arg->{type} . " " . $hr_arg->{name};
        if($hr_arg->{default} ne "") {
          print "=" . $hr_arg->{default};
        }
      } else {
        print "type[" . $hr_arg->{type} . "] ";
        print "name[" . $hr_arg->{name} . "] ";
        print "dflt[" . $hr_arg->{default} . "]";
      }
    }
    print ")";
  }
  print "\n";
}

#
# Print the classes' content
# in : ($hr,                reference to a class hash
#       $clean)             when set, indicates to hide the hash details
sub PrintClasses {
  my ($hr, $clean) = @_;
  my $str = "";
  if(exists $hr->{class}) {
    $str = $hr->{class};
    if($clean) {print "class ${str} ";}
    else       {print "class[${str}] ";}
  }
  print "\n";
  foreach my $ar_items (@{$hr->{items}}) {
    foreach my $hr_item (@$ar_items) {
      PrintClassItems(\%$hr_item, $clean);
    }
  }
}

#
# Remove extra spaces and/or newlines between each string elements
# in : ($string)            string to clean
# out: ($string)            cleaned string
sub CleanStrings {
  my ($string) = @_;
  chomp($string);
  my @split_string = split(' ',$string);
  chomp(@split_string);
  return $string = join(' ',@split_string);
}

#
# Extract group arguments as defined in ExtractGroupItems()
# in : ($group_args)        group arguments to extract
# out: (\@arguments)        reference to an array of argument hashes
sub ExtractGroupArguments {
  my ($group_args) = @_;
  my @arguments = ();       # array of argument hashes
  # split the arguments (comma separated)
  my @group_args = split(',', $group_args);
  # extract each argument information
  foreach my $arg (@group_args) {
    my %args = ();      # argument hashes
    # split at the default value boundary, if any
    my @default = split('=',$arg);
    # get the default value, if any
    if(scalar @default > 1) {
      $args{default} = pop(@default);
    # ensure default key is initialized even if there is no default value
    } else {
      $args{default} = "";
    }
    # split again at the word boundary
    my @words = split(' ',$default[0]);
    # get the argument name, i.e. last element
    $args{name} = pop(@words);
    # get the argument qualifiers
    $args{type} = join(' ',@words);
    push @arguments, \%args;
  }
  return \@arguments;
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
# data structure
# [] represent an array
# {} represent a hash
#
# @classes = (
#   [
#     {
#       class => "<class>",   # class scope (filled by ExtractClasses())
#       items => [
#         {
#           group => "<group>",       # function/task
#           quals => "<quals>",       # qualifiers as shown above
#           rtype => "<rtype>",       # returned type
#           name  => "<name>",        # function/task identifier
#           sargs => "<str args>",    # string of arguments (not broken down)
#           args  => [                # broken down arguments (filled by ExtractGroupArguments())
#             { type => "<type>", name => "<name>", default => "<default>" },     # one hash per argument
#           ],
#         },
#       ],
#     },
#   ],
# );
#
# in : ($targets,     groups to search for (function, task, function|task)
#       $prototype)   group prototype, can spread on multiple lines
# out: (\%items)      reference to a group items hash
#
sub ExtractGroupItems {
  my ($targets, $prototype) = @_;
  my %items = ();
  if($prototype =~ /([\s|\w]*)(${targets})\s+(new|[\w]*)\s*([\w]*)\s*\(([^\)]*)\);/sx) {
    $items{group} = $2;
    $items{quals} = CleanStrings($1);
    $items{sargs} = CleanStrings($5);
    $items{args}  = ExtractGroupArguments($items{sargs});
    if($3 ne "new") {
      $items{rtype} = $3;
      $items{name}  = $4;
    } else {
      $items{rtype} = "";
      $items{name}  = $3;
    }
  }
  return \%items;
}

#
# Extract the groups of interest of all class(es) found in the specified file
# in : ($filename,          file to parse
#       $ar_targets,        reference of an array of groups to search for (function, task, function|task)
#       $ar_qualifiers)     reference of an array of group qualifiers to search for (see ExtractGroupItems() header)
# out: (\@classes)          reference of an array of class hash
sub ExtractClasses {
  my ($filename, $ar_targets, $ar_qualifiers) = @_;
  open FH, '<', "${filename}" or die "Can't open ${filename} $!\n";
  my @scope = ();           # array to keep track of the classes scope
  my @items = ();           # array of a class items hash
  my @class_names = ();     # array of class names            (@class_names[<index>])
  my @class_items = ();     # array of arrays of class items  (@class_items[<index>][<items>])
  # create a target search string based on the specified targets
  my $target_str = join('|',@$ar_targets);
  # in order to skip the "end<target>" strings, create an end-targets string based on the specified targets
  # make a local copy of the targets array to avoid modifying it
  my @end_targets = @$ar_targets;
  map($_ = "end$_", @end_targets);
  my $end_target_str = join('|',@end_targets);
  # create a qualifier search string based on the specified qualifiers
  my $qualifier_str = join('|',@$ar_qualifiers);
  {
    local $/ = "";    # paragraph mode
    while(<FH>) {
      my $prototype = "";
      # split the paragraph into lines
      my @lines = split(/\n/,$_);
      LINE: for my $line (@lines) {
        next LINE if($line =~ /^\s*\/\//);            # skip commented lines
        next LINE if($line =~ /.*::/);                # skip lines with class scope operator "::"
        next LINE if($line =~ /^\s*${end_target_str}/x); # skip lines with "end<target>"
        # beginning of a class
        if($line =~ /^([\s]*|virtual)\s*class\s*([\w]*)/x) {
          push @scope, $2;
          print "processing " . join('::', @scope) . "\n" if($verbose);
          push @class_names, join('::', @scope);
        # end of a class
        } elsif($line =~ /^\s*endclass/) {
          print "done processing " . join('::', @scope) . " - found " . scalar @items . " item(s)\n" if($verbose);
          pop @scope;
          push @class_items, [ @items ];
          @items = ();
        # content of a class
        } elsif(scalar @scope) {
          # use the flip-flop operator to identify the start/end of a group
          if(($line =~ /^([\s|\w]*)(${qualifier_str})\s*(${target_str})/ .. /\s*;/x) || ($prototype ne "")) {
            $prototype .= "$line\n";
            # end of a group
            if($line =~ /;/) {
              print $prototype if($verbose);
              push @items, [ ExtractGroupItems($target_str, $prototype) ];
              $prototype = "";
            }
          }
        }
      }
    }
  }
  # fit both class names and items arrays in an array of hashes
  # sanity check
  if(scalar @class_names ne scalar @class_items) {
    die "Something went wrong!\nNumber of class(es) (" . scalar @class_names . "), doesn't match the number of class items arrays (" . scalar @class_items . ")!\n";
  }
  my %class = ();           # class hash (name + items)
  my @classes = ();         # array of class hashes
  for my $i (0 .. $#class_names) {
    $class{class} = $class_names[$i];
    $class{items} = [ @{$class_items[$i]} ];
    push @classes, { %class };
  }
  close(FH);
  return ( \@classes );
}

#
# Generate a test double of a class using the specified functions
#
# TODO: Add support for nested classes
#
# in : ($name,              nome of the file whose content was extracted
#       $suffix,            suffix of the file
#       $ar_classes)        reference to an array of class hash
# out: ($filename)          output file name including suffix
sub GenerateTestDouble {
  my ($name, $suffix, $ar_classes) = @_;
  my $filename = "test_${name}_double";
  open(FH, '>', "${filename}${suffix}") or die "Can't open ${filename}${suffix} $!\n";
  print FH "`ifndef __" . uc(${filename}) . "__\n";
  print FH "`define __" . uc(${filename}) . "__\n";
  print FH "\n";
  print FH "import uvm_pkg::*;\n";
  print FH "`include \"uvm_macros.svh\"\n";
  print FH "\n";
  for my $i (0 .. $#{$ar_classes}) {
    my $hr = @$ar_classes[$i];
    my $dbl_class_name = "test_" . $hr->{class} . "_double";
    print FH "class ${dbl_class_name} extends " . $hr->{class} . ";\n";
    # create a variable to keep track if the extracted groups are called
    foreach my $ar_items (@{$hr->{items}}) {
      foreach my $hr_item (@$ar_items) {
        next if($hr_item->{name} eq "new");
        print FH "  bit " . $hr_item->{name} . "_called = 0;\n";
      }
    }
    print FH "\n";
    # create the new function if it was captured
    foreach my $ar_items (@{$hr->{items}}) {
      foreach my $hr_item (@$ar_items) {
        if($hr_item->{name} eq "new") {
          print FH "  function new(" . $hr_item->{sargs} . ");\n";
          print FH "    super.new(";
          for my $i (0 .. $#{$hr_item->{args}}) {
            my $hr_arg = ${$hr_item->{args}}[$i];
            if($i > 0) {
              print FH ", ";
            }
            print FH $hr_arg->{name};
          }
          print FH ");\n";;
          print FH "  endfunction\n\n";
        }
      }
    }
    # create each captured group
    foreach my $ar_items (@{$hr->{items}}) {
      foreach my $hr_item (@$ar_items) {
        next if($hr_item->{name} eq "new");
        # remove any 'extern' or 'pure' qualifiers as this generated class has its implementation inline
        my $quals = $hr_item->{quals};
        $quals =~ s/extern|pure//g;
        $quals = CleanStrings($quals);
        print FH "  ";
        print FH "$quals " if($quals ne "");
        print FH $hr_item->{group} . " ". $hr_item->{rtype} . " " . $hr_item->{name} . "(" . $hr_item->{sargs} . ");\n";
        print FH "    " . $hr_item->{name} . "_called = 1;\n";
        my $rtype = $hr_item->{rtype};
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
        print FH "  end" . $hr_item->{group} . "\n\n";
      }
    }
    print FH "endclass\n";
    print FH "\n";
  }
  print FH "`endif";
  close(FH);
  return "${filename}${suffix}";
}


######################################################################
# Main
######################################################################
STDOUT->autoflush(1);

my $verbose_clean = 0;
my $gen_test_dbl  = 0;
my $target_func   = 0;
my $target_task   = 0;
my @targets       = ();
my @qualifiers    = ();
my $filename      = "";

if(scalar @ARGV > 0) {
  while(my $arg = shift(@ARGV)) {
    if($arg =~ /--help/) {
      PrintUsage();
      exit(1);
    } elsif($arg =~ /^-([^\s|.]+)/) {
      my @switches = split('',$1);
      foreach(@switches) {
        if(/c/) {
          $verbose_clean = 1;
        } elsif(/v/) {
          $verbose = 1;
        } elsif(/g/) {
          $gen_test_dbl = 1;
        } elsif(/f/) {
          if(!$target_func) {
            $target_func = 1;
            push @targets, "function";
          }
        } elsif(/t/) {
          if(!$target_task) {
            $target_task = 1;
            push @targets, "task";
          }
        } elsif(/q/) {
          while($_ = $ARGV[0]) {
            if(/[^-]/) {
              push @qualifiers, $_;
              shift(@ARGV);
            } elsif (/--/) {
              shift(@ARGV);
              last;
            } else {
              last;
            }
          }
        }
      }
    } elsif($filename eq "") {
      $filename = $arg;
    } else {
      PrintUsage();
      exit(1);
    }
  }
} else {
  PrintUsage();
  exit(1);
}

# debug
#foreach(@targets) {
#  print "target         : $_\n";
#}
#foreach(@qualifiers) {
#  print "qualifier      : $_\n";
#}
#print "verbose        : $verbose\n";
#print "verbose_clean  : $verbose_clean\n";
#print "gen_test_dbl   : $gen_test_dbl\n";
#print "filename       : $filename\n";
#exit(1);

my $ar_classes = ExtractClasses($filename, \@targets, \@qualifiers);

if($verbose) {
  print "\nDone parsing $filename for targets (" . join('|',@{targets}) . ") and qualifiers (" . join('|',@{qualifiers}) . "):\n";
  for my $i (0 .. $#{$ar_classes}) {
    PrintClasses($ar_classes->[$i], $verbose_clean);
  }
}

if($gen_test_dbl) {
  my ($name, $path, $suffix) = fileparse($filename, qr/\.[^.]*/);
  my $filename = GenerateTestDouble($name, $suffix, $ar_classes);
  if($verbose) {
    print "\nDone generating ${filename}\n";
  }
}

