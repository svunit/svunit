//###########################################################################
//
//  Copyright 2021-2023 The SVUnit Authors.
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


class filter_for_single_pattern;

  local static const string error_msg = "Expected the filter to be of the type '<test_case>.<test>[:<test_case>.<test>]'";

  local const string testcase;
  local const string test;


  function new(string pattern);
    int unsigned dot_idx = get_dot_idx(pattern);

    testcase = pattern.substr(0, dot_idx-1);
    disallow_partial_wildcards("testcase", testcase);

    test = pattern.substr(dot_idx+1, pattern.len()-1);
    disallow_partial_wildcards("test", test);
  endfunction


  local function int unsigned get_dot_idx(string pattern);
    int unsigned first_dot_idx = get_first_dot_idx(pattern);
    ensure_no_more_dots(pattern, first_dot_idx);
    return first_dot_idx;
  endfunction


  local function int unsigned get_first_dot_idx(string pattern);
    for (int i = 0; i < pattern.len(); i++)
      if (pattern[i] == ".")
        return i;
`ifndef XILINX_SIMULATOR
    $fatal(0, error_msg);
`else
    $fatal(error_msg);
`endif
  endfunction


  local function void ensure_no_more_dots(string pattern, int unsigned first_dot_idx);
    for (int i = first_dot_idx+1; i < pattern.len(); i++)
      if (pattern[i] == ".")
`ifndef XILINX_SIMULATOR
        $fatal(0, error_msg);
`else
        $fatal(error_msg);
`endif
  endfunction


  local function void disallow_partial_wildcards(string field_name, string field_value);
    if (field_value != "*")
      if (str_contains_char(field_value, "*"))
`ifndef XILINX_SIMULATOR
        $fatal(0, $sformatf("Partial wildcards in %s names aren't currently supported", field_name));
`else
        $fatal($sformatf("Partial wildcards in %s names aren't currently supported", field_name));
`endif
  endfunction


  local static function bit str_contains_char(string s, string c);
    if (c.len() != 1)
`ifndef XILINX_SIMULATOR
      $fatal(0, "Expected a single character");
`else
      $fatal("Expected a single character");
`endif
    foreach (s[i])
      if (s[i] == c[0])
        return 1;
    return 0;
  endfunction


  virtual function bit is_selected(svunit_testcase tc, string test_name);
    if (is_match(this.testcase, tc.get_name()) && is_match(this.test, test_name))
      return 1;
    return 0;
  endfunction


  local function bit is_match(string filter_val, string val);
    return (filter_val == "*") || (filter_val == val);
  endfunction

endclass
