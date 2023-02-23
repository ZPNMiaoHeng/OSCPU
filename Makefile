#************************************************************************************************
#* V 2.1.1
#* Date: 11/9 2022
#* **********************************************************************************************
# run_riscv：riscv-tests TOP=指定文件名
# riscv_tests：riscv-tests TOP=指定文件名
# 总线测试：需要取消注释 FLASS +=  WITH_DRAMSIM3=1
#************************************************************************************************
# Modefly：
# ++ 1.Interrupt test; 2.hello test; 3.performance test
#************************************************************************************************
# EXAMPLE: make run_riscv TOP=add   // 测试riscv目录下add执行
#************************************************************************************************
.PHONY : clean test_cpu test_riscv coremark run_riscv run_cpu axi vcd dhrystone interrupt hello

TARGET = chisel_cpu_diff
TOOLS = ./build.sh -e $(TARGET)
FLASS = EMU_TRACE=1
FLASS += WITH_DRAMSIM3=1
VCD = 
TOP=

test_cpu:
	$(TOOLS) -b -r "non-output/cpu-tests" -m "$(FLASS)"

test_riscv:
	$(TOOLS) -b -r "non-output/riscv-tests" -m "$(FLASS)"

# test cpu performance
coremark:
	$(TOOLS) -d -b -s -a "-i non-output/coremark/coremark.bin " -m "$(FLASS)"

dhrystone:
	$(TOOLS) -d -b -s -a "-i non-output/dhrystone/dhrystone.bin " -m "$(FLASS)"

huge:
	$(TOOLS) -d -b -s -a "-i non-output/microbench/microbench-huge.bin $(VCD)" -m "$(FLASS)"
ref:
	$(TOOLS) -d -b -s -a "-i non-output/microbench/microbench-ref.bin $(VCD)" -m "$(FLASS)"
test:
	$(TOOLS) -d -b -s -a "-i non-output/microbench/microbench-test.bin $(VCD) " -m "$(FLASS)"
train:
	$(TOOLS) -d -b -s -a "-i non-output/microbench/microbench-train.bin $(VCD)" -m "$(FLASS)"

interrupt:
	$(TOOLS) -d -b -s -a "-i custom-output/interrupt-test/amtest-interrupt-test.bin $(VCD)" -m "$(FLASS)"

hello:
	$(TOOLS) -d -b -s -a "-i custom-output/hello/amtest-hello.bin " -m "$(FLASS)"

mario:
	$(TOOLS) -d -b -s -a "-i custom-output/mario/fceux-mario.bin " -m "$(FLASS)"

rtthread:
	$(TOOLS) -d -b -s -a "-i custom-output/rt-thread/rtthread.bin " -m "$(FLASS)"

time:
	$(TOOLS) -d -b -s -a "-i custom-output/time-test/amtest-time-test.bin " -m "$(FLASS)"

yield:
	$(TOOLS) -d -b -s -a "-i custom-output/yield-test/amtest-yield-test.bin " -m "$(FLASS)"

# run indecation tests
run_riscv:
	$(TOOLS) -d -b -s -a "-i non-output/riscv-tests/$(TOP)-riscv-tests.bin --dump-wave -b 0" -m "$(FLASS)"

run_cpu:
	$(TOOLS) -d -b -s -a "-i non-output/cpu-tests/$(TOP)-cpu-tests.bin --dump-wave -b 0" -m "$(FLASS)"

# test axi
axi:
	$(TOOLS) -d -b -s -a "-i inst_diff.bin --dump-wave -b 0" -m "$(FLASS)"

vcd:
	$(TOOLS) -d -w

clean:
	$(TOOLS) -c
	rm -rf $(VSRC)
