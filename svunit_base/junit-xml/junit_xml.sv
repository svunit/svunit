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

package junit_xml;

  `include "TestSuite.svh"


  function automatic string to_xml_report_string(TestSuite test_suite);
    string result;
    string lines[$];
    lines.push_back($sformatf("<testsuites>"));
    lines.push_back($sformatf("  <testsuite name=\"%s\">", test_suite.get_name()));
    lines.push_back($sformatf("  </testsuite>"));
    lines.push_back($sformatf("</testsuites>"));

    foreach (lines[i]) begin
      if (i == 0) begin
        result = lines[i];
        continue;
      end

      result = { result, "\n", lines[i] };
    end
    return result;
  endfunction

endpackage
