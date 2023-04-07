//###########################################################################
//
//  Copyright 2021-2022 The SVUnit Authors.
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

  /* local */ typedef class filter_for_single_pattern;

  /* local */ typedef filter_for_single_pattern array_of_filters[];
  /* local */ typedef string array_of_string[];

  /* local */ typedef struct {
    string positive;
    string negative;
  } filter_expression_parts;


  local static const string error_msg = "Expected the filter to be of the type '<test_case>.<test>[:<test_case>.<test>]'";
  local static filter single_instance;

  local const filter_for_single_pattern positive_subfilters[];
  local const filter_for_single_pattern negative_subfilters[];


  static function filter get();
    if (single_instance == null)
      single_instance = new();
    return single_instance;
  endfunction


  local function new();
    string raw_filter = get_filter_value_from_run_script();
    filter_expression_parts parts = get_filter_expression_parts(raw_filter);
    positive_subfilters = get_subfilters(parts.positive);
    if (parts.negative != "")
      negative_subfilters = get_subfilters(parts.negative);
  endfunction


  local function string get_filter_value_from_run_script();
    string result;
    if (!$value$plusargs("SVUNIT_FILTER=%s", result))
      result = "*";
    return result;
  endfunction


  local function filter_expression_parts get_filter_expression_parts(string raw_filter);
    string parts[];

    if (raw_filter[0] == "-")
      raw_filter = { "*", raw_filter };

    parts = string_utils::split_by_char("-", raw_filter);
    if (parts.size() > 2)
      $fatal(0, "Expected at most a single '-' character.");

    if (parts.size() == 1)
      return '{ parts[0], "" };
    return '{ parts[0], parts[1] };
  endfunction


  local function array_of_filters get_subfilters(string raw_filter);
    filter_for_single_pattern result[$];
    string patterns[];

    if (raw_filter == "*") begin
      filter_for_single_pattern filter_that_always_matches = new("*.*");
      return '{ filter_that_always_matches };
    end

    patterns = string_utils::split_by_char(":", raw_filter);
    foreach (patterns[i])
      result.push_back(get_subfilter_from_non_trivial_expr(patterns[i]));
    return result;
  endfunction


  local function filter_for_single_pattern get_subfilter_from_non_trivial_expr(string pattern);
    filter_for_single_pattern result;
    result = new(pattern);
    return result;
  endfunction


  function bit is_selected(svunit_testcase tc, string test_name);
    foreach (negative_subfilters[i])
      if (negative_subfilters[i].is_selected(tc, test_name))
        return 0;

    foreach (positive_subfilters[i])
      if (positive_subfilters[i].is_selected(tc, test_name))
        return 1;

    return 0;
  endfunction


  class filter_for_single_pattern;

    local const string testcase;
    local const string test;

    function new(string pattern);
      int unsigned dot_idx = get_dot_idx(pattern);

      testcase = pattern.substr(0, dot_idx-1);
      disallow_partial_wildcards("testcase", testcase);

      test = pattern.substr(dot_idx+1, pattern.len()-1);
      disallow_partial_wildcards("test", test);
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

    virtual function bit is_selected(svunit_testcase tc, string test_name);
      if (is_match(this.testcase, tc.get_name()) && is_match(this.test, test_name))
        return 1;
      return 0;
    endfunction

    local function bit is_match(string filter_val, string val);
      return (filter_val == "*") || (filter_val == val);
    endfunction

  endclass

endclass
