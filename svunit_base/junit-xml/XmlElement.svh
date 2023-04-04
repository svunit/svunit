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

class XmlElement;

  local const string tag;
  local string attributes[string];
  local XmlElement children[$];


  function new(string tag);
    this.tag = tag;
  endfunction


  function void set_attribute(string name, string value);
    attributes[name] = value;
  endfunction


  function void add_child(XmlElement child);
    children.push_back(child);
  endfunction


  function string as_string();
    return as_string_with_indent("");
  endfunction


  local function string as_string_with_indent(string indent);
    string result;
    `ifndef VERILATOR
      result = $sformatf("%s<%s>", indent, get_start_tag_contents);
    `else
      string lv_vlt_s;
      lv_vlt_s = get_start_tag_contents();
      result = $sformatf("%s<%s>", indent, lv_vlt_s);
    `endif // VERILATOR
    foreach (children[i]) begin
      // XXX WORKAROUND Xcelium messes up the indentation if we try to inline the following
      // variable.
      string child_indent = { indent, "  " };
      `ifndef VERILATOR
        result = { result, "\n", children[i].as_string_with_indent(child_indent) };
      `endif // VERILATOR
    end
    result = { result, "\n", $sformatf("%s</%s>", indent, tag) };
    return result;
  endfunction


  local function string get_start_tag_contents();
    string result = tag;
    foreach (attributes[i])
      result = { result, " ", $sformatf("%s=\"%s\"", i, attributes[i])};
    return result;
  endfunction

endclass
