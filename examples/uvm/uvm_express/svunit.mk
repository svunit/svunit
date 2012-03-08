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

SIMULATOR := QUESTA

ifeq ($(SIMULATOR),QUESTA)
TESTFILES += $(UVM_HOME)/src/uvm.sv \
					$(SVUNIT_INSTALL)/svunit_base/uvm-mock/svunit_uvm_mock_pkg.sv
INCDIR += $(UVM_HOME)/src \
					$(SVUNIT_INSTALL)/svunit_base/uvm-mock
SIM_ARGS += +define+CLK_PERIOD=5 \
						-R \
               -sv_lib $(UVM_HOME)/lib/uvm_dpi32 \
               +UVM_NO_RELNOTES \
            -

include $(SVUNIT_INSTALL)/bin/questa.mk
endif

ifeq ($(SIMULATOR),VCS)
TESTFILES += $(UVM_HOME)/src/uvm.sv \
						 $(SVUNIT_INSTALL)/svunit_base/uvm-mock/svunit_uvm_mock_pkg.sv \
						 $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS
INCDIR += $(UVM_HOME)/src \
					$(SVUNIT_INSTALL)/svunit_base/uvm-mock
SIM_ARGS += +define+CLK_PERIOD=5 \
				    +UVM_NO_RELNOTES

SIM_EXE=vcsi
include $(SVUNIT_INSTALL)/bin/vcs.mk
endif
