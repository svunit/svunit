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

##########################################################################
# Global Variables
##########################################################################
$date        = `date +%B" "%d", "%G`;
$author      = "XtremeEDA Corp";
$header_file = "$ENV{SVUNIT_INSTALL}/bin/header.txt";
$script_dir  = "$ENV{SVUNIT_INSTALL}/bin";

@exclude     = ("clone", 
                "compare", 
                "covert2string", 
                "print", 
                "sprint", 
                "run", 
                "connect", 
                "export_connections", 
                "import_connections", 
                "configure", 
                "report",
                "pre_randomize", 
                "post_randomize"
               );

use Env qw(PWD);

$pwd = $PWD;
@cwd = split(/\//, $pwd);
$size = $#cwd;
$pwd = @cwd[$size];
