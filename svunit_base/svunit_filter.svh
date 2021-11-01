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
  local const filter_parts_t filter_parts;


  local function new();
    string raw_filter;
    if (!$value$plusargs("SVUNIT_FILTER=%s", raw_filter))
      $fatal(0, "Expected to receive a plusarg called 'SVUNIT_FILTER'");
    this.filter_parts = parse_filter_parts(raw_filter);
  endfunction


  local function filter_parts_t parse_filter_parts(string filter);
    filter_parts_t result;
    const string error_msg = "Expected the filter to be of the type '<test_case>.<test>'";
    int dot_idx = -1;

    if (filter == "*") begin
      result.testcase = "*";
      result.test = "*";
      return result;
    end

    for (int i = 0; i < filter.len(); i++)
      if (filter[i] == ".") begin
        dot_idx = i;
        break;
      end
    if (dot_idx == -1)
      $fatal(0, error_msg);

    for (int i = dot_idx+1; i < filter.len(); i++)
      if (filter[i] == ".")
        $fatal(0, error_msg);

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
