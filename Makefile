#************************************************************************************************
#* V 1.1.1
#* Date: Six, 6/8 2022
#* run_riscv：riscv-tests , TOP 指定文件名
#* riscv_tests：riscv-tests , TOP 指定文件
#************************************************************************************************

DIR = ./projects/chisel_cpu_diff/vsrc/SimTop.v
TARGET = chisel_cpu_diff
TOOLS = ./build.sh -e $(TARGET)
TOPC = inst_diff
FLASS = 
TOP=

cpu_tests:
	$(TOOLS) -b -r "non-output/cpu-tests"

riscv_tests:
	$(TOOLS) -b -r "non-output/riscv-tests"

run_riscv:
	$(TOOLS) -d -b -s -a "-i non-output/riscv-tests/$(TOP)-riscv-tests.bin --dump-wave -b 0" -m "EMU_TRACE=1 WITH_DRAMSIM3=1"
#	./build.sh -e chisel_cpu_diff -d -b -s -a "-i inst_diff.bin --dump-wave -b 0" -m "EMU_TRACE=1"

run_cpu:
	$(TOOLS) -d -b -s -a "-i non-output/cpu-tests/$(TOP)-cpu-tests.bin --dump-wave -b 0" -m "EMU_TRACE=1"

vcd:
	$(TOOLS) -w

clean:
	$(TOOLS) -c

.PHONY : run test verilog clean 