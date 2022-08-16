import chisel3._
import chisel3.util._
import difftest._
/**
  ** 总线：第一次测试 读取指令阶段
  ** --访存数据不变，取指阶段换成总线--
  */

class SimTop extends Module {
  val io = IO(new Bundle {
    val logCtrl = new LogCtrlIO
    val perfInfo = new PerfInfoIO
    val uart = new UARTIO

    val memAXI_0 = new AxiIO
  })

  val core = Module(new Core)
  val icache = Module(new Icache)

  val mem = Module(new Ram2r1w)
  val top = Module(new AxiLite2Axi)

//  top.io.imem <> core.io.imem
  core.io.imem  <> icache.io.imem
  icache.io.out <> top.io.imem

  io.memAXI_0.aw <> top.io.out.aw
  io.memAXI_0.w  <> top.io.out.w
  io.memAXI_0.b  <> top.io.out.b
  io.memAXI_0.ar <> top.io.out.ar
  io.memAXI_0.r  <> top.io.out.r
  
//  mem.io.imem <> core.io.imem
  mem.io.dmem <> core.io.dmem

  io.uart.out.valid := false.B
  io.uart.out.ch := 0.U
  io.uart.in.valid := false.B

}
