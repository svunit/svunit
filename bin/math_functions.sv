############################################################################
#
#  Copyright 2011 The SVUnit Authors.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
############################################################################

//=======================================
// This is just a small class to test
// the create_test.pl script.  Feel free
// to modify or add more tasks/functions.
//=======================================
class math_functions;

  function int adder(int a, int b);
    return a + b;
  endfunction

  function int sub(int a, int b);
    return a - b;
  endfunction

  function int mult(int a, int b);
    return a * b;
  endfunction

  extern function int div(int a, int b);

  local task hello_world();
    $display("Hello World");
  endtask

  /* task square(int a, ref int b);
    b = a*a;
  endtask */

  //task cube(int a, ref int b);
  //  b = a*a*a;
  //endtask

  //function square(int a);
  //  return a*a;
  //endfunction

endclass
