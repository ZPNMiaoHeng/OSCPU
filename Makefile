#************************************************************************************************
#* V 1.1.1
#* run_riscv：riscv-tests , TOP 指定文件名
#* riscv_tests：riscv-tests , TOP 指定文件
#************************************************************************************************


TARGET = chisel_cpu_diff
TOPC = inst_diff
FLASS = 
TOP=

cpu_tests:
	./build.sh -e $(TARGET) -b -r "non-output/cpu-tests"   
riscv_tests:
	./build.sh -e $(TARGET) -b -r "non-output/riscv-tests"
run_riscv:
	./build.sh -e $(TARGET) -d -b -s -a "-i non-output/riscv-tests/$(TOP)-riscv-tests.bin --dump-wave -b 0" -m "EMU_TRACE=1" $(FLASS)
#	./build.sh -e chisel_cpu_diff -d -b -s -a "-i inst_diff.bin --dump-wave -b 0" -m "EMU_TRACE=1"  
run_cpu:
	./build.sh -e $(TARGET) -d -b -s -a "-i non-output/cpu-tests/$(TOP)-cpu-tests.bin --dump-wave -b 0" -m "EMU_TRACE=1" $(FLASS)
vcd:
	./build.sh -e $(TARGET) -d -w

clean:
	./build.sh -e $(TARGET) -c

.PHONY : run test verilog clean 