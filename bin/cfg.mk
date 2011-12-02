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

INCDIR   += .
INCDIR   += $(SVUNIT_INSTALL)/svunit_base

ALLPKGS  += $(SVUNIT_INSTALL)/svunit_base/svunit_pkg.sv $(TESTPKGS)

ifeq ($(SIM_EXE),)
	SIM_EXE  := vcs
endif
SIM_ARGS += -R -sverilog -ntb_opts dtm

space :=
space +=
INCDIRS := +incdir$(subst $(space),,$(foreach DIR,$(INCDIR),+$(DIR)))

# compute the unittest list
UT := $(filter %_UNITTESTS,$(.VARIABLES))
UNITTESTS := $(foreach u,$(UT),$($(u)))

TESTRUNNER := testrunner.sv
SVUNIT_TOP := svunit_top.sv


############## TARGETS ############## 


sim : clean .$(SVUNIT_TOP)
	$(SIM_EXE) \
    $(SIM_ARGS) \
    $(INCDIRS) \
		$(ALLPKGS) \
		$(TESTFILES) \
    $(UNITTESTS) \
    $(TESTSUITES) \
    .$(TESTRUNNER) \
    .$(SVUNIT_TOP)



svunit : FORCE
	exit 1



.$(SVUNIT_TOP) : .$(TESTRUNNER)
	@create_svunit_top.pl -overwrite
	@mv $(SVUNIT_TOP) .$(SVUNIT_TOP)



TEST_RUNNER_ARGS += -overwrite
TEST_RUNNER_ARGS += $(foreach TESTSUITE, $(TESTSUITES), -add $(TESTSUITE))
TEST_RUNNER_ARGS += $(foreach TESTSUITE, $(.TESTSUITES), -add $(TESTSUITE))
TEST_RUNNER_ARGS += -out $(TESTRUNNER)
.$(TESTRUNNER) : $(TESTSUITES) $(.TESTSUITES)
	@create_testrunner.pl $(TEST_RUNNER_ARGS)
	@mv $(TESTRUNNER) .$(TESTRUNNER)


$(.TESTSUITES) :
	@cd `echo $@ | sed -e 's/[^/]*$$//'` && make testsuites && cd -

.SECONDEXPANSION :

TESTSUITE_ARGS += -overwrite
TESTSUITE_ARGS +=  $(foreach UNITTEST, $($*_UNITTESTS), -add $(UNITTEST))
TESTSUITE_ARGS += -out $@
%_testsuite.sv : $$($$*_UNITTESTS)
	create_testsuite.pl $(TESTSUITE_ARGS)

testsuites : $(TESTSUITES)



clean :
	rm -rf .*testsuite.sv .*testrunner.sv .*svunit_top.sv csrc* simv* vc_hdrs.h

FORCE :
