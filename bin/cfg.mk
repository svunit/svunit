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

############## VARIABLES ############## 

TESTDIR    := $(shell echo `pwd`)

INCDIR   += $(TESTDIR)
INCDIR   += $(SVUNIT_INSTALL)/svunit_base

ALLPKGS  += $(SVUNIT_INSTALL)/svunit_base/svunit_pkg.sv

TESTRUNNER := testrunner.sv
FILELISTS  += $(wildcard svunit.f)
SIM_FLISTS += $(foreach FILE,$(FILELISTS), -file $(FILE))
TESTFILES  += $(SIM_FLISTS) \
							$(CHILD_UNITTESTS) \
              $(UNITTESTS) \
              $(CHILD_TESTSUITES) \
              $(TESTSUITES) \
              $(TESTDIR)/.$(TESTRUNNER) \



############## TARGETS ############## 

# This file is simulator independant which
# means the command line (i.e. SVUNIT_SIM)
# must be formed elsewhere
ifeq ($(SVUNIT_SIM),)
	SVUNIT_SIM=@echo "Error: SVUNIT_SIM command line not defined"
endif



sim : .$(TESTRUNNER)
	@$(SVUNIT_SIM)


svunit : FORCE
	exit 1


TEST_RUNNER_ARGS += -overwrite
TEST_RUNNER_ARGS += $(foreach TESTSUITE, $(TESTSUITES), -add $(TESTSUITE))
TEST_RUNNER_ARGS += $(foreach TESTSUITE, $(CHILD_TESTSUITES), -add $(TESTSUITE))
TEST_RUNNER_ARGS += -out $(TESTRUNNER)
.$(TESTRUNNER) : $(TESTSUITES) $(CHILD_TESTSUITES)
	@create_testrunner.pl $(TEST_RUNNER_ARGS)
	@mv $(TESTRUNNER) .$(TESTRUNNER)


$(CHILD_TESTSUITES) :
	@cd `echo $@ | sed -e 's/[^/]*$$//'` && make testsuites && cd -

.SECONDEXPANSION :

TESTSUITE_ARGS += -overwrite
TESTSUITE_ARGS +=  $(foreach UNITTEST, $(UNITTESTS), -add $(UNITTEST))
TESTSUITE_ARGS += -out $(notdir $@)
$(TESTDIR)/%_testsuite.sv : $(UNITTESTS)
	@create_testsuite.pl $(TESTSUITE_ARGS)

testsuites : $(TESTSUITES)

CLEANFILES += .*testsuite.sv .*testrunner.sv .*svunit_top.sv
clean :
	rm -rf $(CLEANFILES)

FORCE :
