//###########################################################################
//
//  Copyright 2011-2021 The SVUnit Authors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//###########################################################################

// The current testcase that is being executed.
svunit_testcase current_tc;

// The filter to apply on tests
`ifndef VERILATOR
  /* local */ const filter _filter = filter::get();
`endif // VERILATOR
