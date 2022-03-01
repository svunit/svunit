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

  /* local */ typedef struct {
    string testcase;
    string test;
  } filter_parts_t;

  /* local */ typedef filter_parts_t array_of_filter_parts_t[];


  local static const string error_msg = "Expected the filter to be of the type '<test_case>.<test>[:<test_case>.<test>]'";
  local static filter single_instance;

  local const filter_parts_t filter_parts[];


  static function filter get();
    if (single_instance == null)
      single_instance = new();
    return single_instance;
  endfunction


  local function new();
    string raw_filter = get_filter_value_from_run_script();
    filter_parts = get_filter_parts(raw_filter);
  endfunction


  local function string get_filter_value_from_run_script();
    string result;
    if (!$value$plusargs("SVUNIT_FILTER=%s", result))
      $fatal(0, "Expected to receive a plusarg called 'SVUNIT_FILTER'");
    return result;
  endfunction


  local function array_of_filter_parts_t get_filter_parts(string raw_filter);
    if (raw_filter == "*") begin
      filter_parts_t result;
      result.testcase = "*";
      result.test = "*";
      return '{ result };
    end

    for (int i = 0; i < raw_filter.len(); i++) begin
      if (raw_filter[i] == ":") begin
        return '{ 
            get_filter_parts_from_non_trivial_expr(raw_filter.substr(0, i-1)),
            get_filter_parts_from_non_trivial_expr(raw_filter.substr(i+1, raw_filter.len()-1))
            };
      end
    end

    return '{ get_filter_parts_from_non_trivial_expr(raw_filter) };
  endfunction


  local function filter_parts_t get_filter_parts_from_non_trivial_expr(string raw_filter);
    filter_parts_t result;
    int unsigned dot_idx = get_dot_idx(raw_filter);

    result.testcase = raw_filter.substr(0, dot_idx-1);
    disallow_partial_wildcards("testcase", result.testcase);

    result.test = raw_filter.substr(dot_idx+1, raw_filter.len()-1);
    disallow_partial_wildcards("test", result.test);

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
      if (str_contains_char(field_value, "*"))
        $fatal(0, $sformatf("Partial wildcards in %s names aren't currently supported", field_name));
  endfunction


  local static function bit str_contains_char(string s, string c);
    if (c.len() != 1)
      $fatal(0, "Expected a single character");
    foreach (s[i])
      if (s[i] == c[0])
        return 1;
    return 0;
  endfunction


  function bit is_selected(svunit_testcase tc, string test_name);
    foreach (filter_parts[i])
      if (is_match(filter_parts[i].testcase, tc.get_name()) && is_match(filter_parts[i].test, test_name))
        return 1;

    return 0;
  endfunction


  local function bit is_match(string filter_val, string val);
    return (filter_val == "*") || (filter_val == val);
  endfunction

endclass
