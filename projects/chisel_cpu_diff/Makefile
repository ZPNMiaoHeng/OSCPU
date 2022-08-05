#include ../../Makefile
TOP = Core
VERILOG_NAME  = $(TOP)
BUILD_DIR = ./build
######################## mill compile ###############################
test:
	mill -i __.test

verilog: 
	$(call git_commit, "generate verilog")
	mkdir -p $(BUILD_DIR)
	mill -i __.test.runMain Elaborate TopModule=$(VERILOG_NAME) -td $(BUILD_DIR)

verilogTrace: 
	$(call git_commit, "generate verilog")
	mkdir -p $(BUILD_DIR)
	mill -j 4 -i __.test.runMain Elaborate TopModule=$(VERILOG_NAME) -td $(BUILD_DIR) --full-stacktrace

clean:
	rm -rf ./build ./out

.PHONY: clean test verilog verilogTrace clean