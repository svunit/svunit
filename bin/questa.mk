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


#------------------------------
# set the simulator executable
#------------------------------
ifeq ($(SIM_EXE),)
	SIM_EXE  := qverilog
endif


#------------------------------
# simulator command line arguments
#------------------------------
ifneq ($(UVM_HOME),)
SIM_ARGS += +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv -L $(UVM_HOME)
ifneq (@(uname -a | egrep -o "x86_64"),)
SIM_UVM  += -R -sv_lib ${UVM_HOME}/lib/uvm_dpi64
else
SIM_UVM  += -R -sv_lib ${UVM_HOME}/lib/uvm_dpi
endif
endif
SIM_ARGS += -l run.log



#----------------------------------------
# format the incdir list to be simulator
# command line friendly. INCDIR has the
# unformated list of directories
#----------------------------------------
space :=
space +=
SIM_INC += +incdir$(subst $(space),,$(foreach DIR,$(INCDIR),+$(DIR)))


#--------------------------------------------------------------
# Form the command line (SVUNIT_SIM) where
#  ALLPKGS   = sv package definitions
#  TESTFILES = list of required files which already includes:
#                 $(UNITTESTS) \
#                 $(TESTSUITES) \
#                 .$(TESTRUNNER) \
#                 .$(SVUNIT_TOP)
#--------------------------------------------------------------
SVUNIT_SIM = $(SIM_EXE) \
             $(SIM_ARGS) \
             $(SIM_INC) \
             $(ALLPKGS) \
             $(TESTFILES) \
             $(SIM_UVM)


#-----------------------------------------------------------
# Files created by the simulator that need to be cleaned up
#-----------------------------------------------------------
CLEANFILES += work \
							run.log \
							vsim.wlf
