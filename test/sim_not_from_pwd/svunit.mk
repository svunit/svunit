include $(SVUNIT_INSTALL)/bin/vcs.mk
SIM_EXE=vcsi

# redefint SVUNIT_SIM to cd to not_pwd first, then compile and run
SVUNIT_SIM = cd not_pwd && $(SIM_EXE) \
													 $(SIM_ARGS) \
													 $(SIM_INC) \
													 $(ALLPKGS) \
													 $(TESTFILES)
