TARGET=chisel_cpu_diff




test:
	./build.sh -e $(TARGET) -d -s -a "-i non-output/riscv64-npc/dummy-riscv64-npc.bin --dump-wave -b 0" -m "EMU_TRACE=1" -b
vcd:
	./build.sh -e chisel_cpu_diff -d -w

clean:
	./build.sh -e chisel_cpu_diff -c