TARGET=chisel_cpu_diff




test:
	./build.sh -e $(TARGET) -d -s -a "-i non-output/riscv64-npc/dummy-riscv64-npc.bimake n --dump-wave -b 0" -m "EMU_TRACE=1" -bimake
milltest:
	mill -j 4 -i __.test
run:
	./build.sh -e $(TARGET) -d -s -a "-i inst_diff.bin --dump-wave -b 0" -m "EMU_TRACE=1" -b  
vcd:
	./build.sh -e $(TARGET) -d -w

clean:
	./build.sh -e $(TARGET) -c

.PHONY : run test verilog clean 