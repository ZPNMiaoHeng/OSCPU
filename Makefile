#************************************************************************************************
#* V 1.2.1
#* Date: Six, 6/8 2022
#* run_riscv：riscv-tests , TOP 指定文件名
#* riscv_tests：riscv-tests , TOP 指定文件
#* 总线测试：需要取消注释 FLASS +=  WITH_DRAMSIM3=1
#************************************************************************************************
#* Modefly：
#* EXAMPLE: make run_riscv TOP=add   // 测试riscv目录下add执行
#************************************************************************************************
#! 需要修改文件夹目录
VSRC = DIR = ./projects/chisel_cpu_diff/vsrc
DIR = ./projects/chisel_cpu_diff/vsrc/SimTop.v

TARGET = chisel_cpu_diff
#************************************************************************************************
TOOLS = ./build.sh -e $(TARGET)
FLASS = EMU_TRACE=1
#FLASS +=  WITH_DRAMSIM3=1
TOP=

cpu_tests:
	$(TOOLS) -b -r "non-output/cpu-tests" -m "$(FLASS)"

riscv_tests:
	$(TOOLS) -b -r "non-output/riscv-tests" -m "$(FLASS)"

run_riscv:
	$(TOOLS) -d -b -s -a "-i non-output/riscv-tests/$(TOP)-riscv-tests.bin --dump-wave -b 0" -m "$(FLASS)"

run_cpu:
	$(TOOLS) -d -b -s -a "-i non-output/cpu-tests/$(TOP)-cpu-tests.bin --dump-wave -b 0" -m "$(FLASS)"

axi:
	$(TOOLS) -d -b -s -a "-i inst_diff.bin --dump-wave -b 0" -m "$(FLASS)"

vcd:
	$(TOOLS) -d -w

clean:
	$(TOOLS) -c
	rm -rf $(VSRC)

.PHONY : run test verilog clean 