TARGET=chisel_cpu_diff




test:
	./build.sh -e $(TARGET) -d -s -a "-i non-output/riscv64-npc/dummy-riscv64-npc.bimake n --dump-wave -b 0" -m "EMU_TRACE=1" -b
diff:
	./build.sh -e $(TARGET) -d -s -a "-i inst_diff.bin" -m "EMU_TRACE=1" -b  
vcd:
	./build.sh -e $(TARGET) -d -s -aw

clean:
	./build.sh -e $(TARGET) -d -s -a "c