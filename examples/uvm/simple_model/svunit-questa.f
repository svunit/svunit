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

//------------------------------------------------
// export the UVM_HOME to point to an available
// version of UVM. For questa, this makefile
// also requires you compile the dpi manually
//------------------------------------------------
// i.e
//   >export UVM_HOME=~/lib/uvm-1.1a
//------------------------------------------------

$SVUNIT_INSTALL/svunit_base/uvm-mock/svunit_uvm_mock_pkg.sv
+incdir+$SVUNIT_INSTALL/svunit_base/uvm-mock
+define+RUN_SVUNIT_WITH_UVM
