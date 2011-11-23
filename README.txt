################################################################
#
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#  
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing,
#  software distributed under the License is distributed on an
#  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
#  specific language governing permissions and limitations
#  under the License.
#
################################################################

-----------------------------------------------------------
Step-by-step instructions to get a first unit test going...
-----------------------------------------------------------

1) setup the SVUNIT_INSTALL and PATH
>source Setup

2) go somewhere and start a class-under-test
---
  bogus.sv:
    class bogus;
    endclass
---

3) generate the unit test
>create_unit_test.pl bogus.sv

4) create the svunit makefiles
>create_svunit.pl

5a) add tests as methods (OR go to 7b)
---
  bogus_unit_test.sv:
    task run_test();
      super.run_test();
      `INFO("Running Unit Tests for class: ppb_event_timer:");

      test_mytest(); // <-- add this line to invoke the test
    endtask

    task test_mytest(); // <-- add the actual test
      `INFO("Running atm_cell::test_calculate_hec");
      /* Place Test Code Here */
    endtask
---

5b) add tests using the helper macros
---
  bogus_unit_test.sv:
    `SVUNIT_TESTS_BEGIN
    //===================================
    // Unit test: test_mytest
    //===================================
    `SVTEST(test_mytest)
    `SVTEST_END(test_mytest)
---

6a) run the unittests
>make sim

6b) or if you only want to build the framework but not run it...
>make .svunit_top.sv

7) repeat steps 5a/5b and 6a until done
