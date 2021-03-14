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
 * Models a JUnit test case. Note that this is not the same concept as an
 * SVUnit test case. A test case in JUnit refers to a test method, but a test
 * case in SVUnit currently refers to a module containing test methods.
 *
 * @see TestSuite
 */
class TestCase;

  local const string name;
  local const string class_name;
  local XmlElement failure;


  function new(string name, string class_name);
    this.name = name;
    this.class_name = class_name;
  endfunction


  function string get_name();
    return name;
  endfunction


  function void add_failure(string message);
    failure = new("failure");
    failure.set_attribute("message", message);
    failure.set_attribute("type", "failure");
  endfunction


  function XmlElement as_xml_element();
    XmlElement result = new("testcase");
    result.set_attribute("name", name);
    result.set_attribute("classname", class_name);
    if (failure != null)
      result.add_child(failure);
    return result;
  endfunction

endclass
