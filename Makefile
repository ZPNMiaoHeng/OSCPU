TARGET=chisel_cpu_diff




test:
	./build.sh -e $(TARGET) -d -s -a "-i non-output/riscv64-npc/dummy-riscv64-npc.bimake n --dump-wave -b 0" -m "EMU_TRACE=1" -bimake

run:
	./build.sh -e $(TARGET) -d -b -s -a "-i inst_diff.bin --dump-wave -b 0" -m "EMU_TRACE=1" -w
#	./build.sh -e cpu_diff -d -b -s -a "-i inst_diff.bin --dump-wave -b 0" -m "EMU_TRACE=1" -w
vcd:
	./build.sh -e $(TARGET) -d -w

clean:
	./build.sh -e $(TARGET) -c

.PHONY : run test verilog clean 