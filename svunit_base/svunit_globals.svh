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

/**
 * The filter expression that controls which tests should run.
 */
const string filter = get_filter();


/* local */ function automatic string get_filter();
  string result;
  if (!$value$plusargs("SVUNIT_FILTER=%s", result))
    $fatal(0, "Expected to receive a plusarg called 'SVUNIT_FILTER'");
  return result;
endfunction


/* local */ typedef struct {
  string testcase;
  string test;
} filter_parts_t;


/* local */ function automatic bit is_selected(svunit_testcase tc, string test_name);
  filter_parts_t filter_parts;

  if (filter == "*")
    return 1;

  filter_parts = parse_filter_parts();
  if (is_match(filter_parts.testcase, tc.get_name()) && is_match(filter_parts.test, test_name))
    return 1;

  return 0;
endfunction


/* local */ function automatic bit is_match(string filter_val, string val);
  return (filter_val == "*") || (filter_val == val);
endfunction


/* local */ function automatic filter_parts_t parse_filter_parts();
  filter_parts_t result;
  const string error_msg = "Expected the filter to be of the type '<test_case>.<test>'";
  int dot_idx = -1;

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
  result.test = filter.substr(dot_idx+1, filter.len()-1);
  return result;
endfunction
