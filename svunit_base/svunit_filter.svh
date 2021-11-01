//###########################################################################
//
//  Copyright 2021 The SVUnit Authors.
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


/**
 * The filter expression that controls which tests should run.
 */
class filter;

  local static const filter single_instance = new();
  local static const string error_msg = "Expected the filter to be of the type '<test_case>.<test>'";

  local const struct {
    string testcase;
    string test;
  } filter_parts;


  local function new();
    string raw_filter = get_filter_value_from_run_script();
    int unsigned dot_idx;

    if (raw_filter == "*") begin
      filter_parts.testcase = "*";
      filter_parts.test = "*";
      return;
    end

    dot_idx = get_dot_idx(raw_filter);

    filter_parts.testcase = raw_filter.substr(0, dot_idx-1);
    disallow_partial_wildcards("testcase", filter_parts.testcase);

    filter_parts.test = raw_filter.substr(dot_idx+1, raw_filter.len()-1);
    disallow_partial_wildcards("test", filter_parts.test);
  endfunction


  local function string get_filter_value_from_run_script();
    string result;
    if (!$value$plusargs("SVUNIT_FILTER=%s", result))
      $fatal(0, "Expected to receive a plusarg called 'SVUNIT_FILTER'");
    return result;
  endfunction


  local function int unsigned get_dot_idx(string filter);
    int unsigned first_dot_idx = get_first_dot_idx(filter);
    ensure_no_more_dots(filter, first_dot_idx);
    return first_dot_idx;
  endfunction


  local function int unsigned get_first_dot_idx(string filter);
    for (int i = 0; i < filter.len(); i++)
      if (filter[i] == ".")
        return i;
    $fatal(0, error_msg);
  endfunction


  local function void ensure_no_more_dots(string filter, int unsigned first_dot_idx);
    for (int i = first_dot_idx+1; i < filter.len(); i++)
      if (filter[i] == ".")
        $fatal(0, error_msg);
  endfunction


  local function void disallow_partial_wildcards(string field_name, string field_value);
    if (field_value != "*")
      if ("*" inside { field_value })
        $fatal(0, $sformatf("Partial wildcards in %s names aren't currently supported", field_name));
  endfunction


  static function filter get();
    return single_instance;
  endfunction


  function bit is_selected(svunit_testcase tc, string test_name);
    if (is_match(filter_parts.testcase, tc.get_name()) && is_match(filter_parts.test, test_name))
      return 1;

    return 0;
  endfunction


  local function bit is_match(string filter_val, string val);
    return (filter_val == "*") || (filter_val == val);
  endfunction

endclass
