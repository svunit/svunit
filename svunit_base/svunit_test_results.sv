//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################

class svunit_test_results;

  string name;

  int error_count = 0;

  boolean_t success;

  static string list_of_failures[$];
  static string list_of_successes[$];

  time start_time;
  time end_time;

  extern function new(string name);
  extern task add_error(string s);
  extern task add_failure(string name);
  extern task add_success(string name);
  extern task start_test();
  extern task stop_test();

endclass


function svunit_test_results::new(string name);
  this.name = name;
endfunction


task svunit_test_results::add_error(string s);
  error_count++;
  $display("[%0tns]: ERROR: [%s] %s", $time, name, s);
endtask


task svunit_test_results::add_failure(string name);
  list_of_failures.push_back(name); 
endtask


task svunit_test_results::add_success(string name);
  list_of_successes.push_back(name); 
endtask


task svunit_test_results::start_test();
  start_time = $time;
endtask


task svunit_test_results::stop_test();
  end_time = $time;
endtask
