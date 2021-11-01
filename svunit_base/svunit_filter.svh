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


  local static const filter single_instance = new();
  local static const string error_msg = "Expected the filter to be of the type '<test_case>.<test>'";
  local const filter_parts_t filter_parts;


  local function new();
    string raw_filter;
    if (!$value$plusargs("SVUNIT_FILTER=%s", raw_filter))
      $fatal(0, "Expected to receive a plusarg called 'SVUNIT_FILTER'");
    this.filter_parts = parse_filter_parts(raw_filter);
  endfunction


  local function filter_parts_t parse_filter_parts(string filter);
    filter_parts_t result;
    int unsigned dot_idx;

    if (filter == "*") begin
      result.testcase = "*";
      result.test = "*";
      return result;
    end

    dot_idx = get_dot_idx(filter);

    result.testcase = filter.substr(0, dot_idx-1);
    if (result.testcase != "*")
      if ("*" inside { result.testcase })
        $fatal(0, "Partial wildcards in testcase names aren't currently supported");

    result.test = filter.substr(dot_idx+1, filter.len()-1);
    if (result.test != "*")
      if ("*" inside { result.test })
        $fatal(0, "Partial wildcards in test names aren't currently supported");

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
