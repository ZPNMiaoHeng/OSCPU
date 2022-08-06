import chisel3._
import chisel3.util._
import Constant._

class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new RomIO
    val nextPC = Input(UInt(WLEN.W))
    val pc = Output(UInt(WLEN.W))
    val inst = Output(UInt(WLEN.W))

  })
  val pc = RegInit("h7fff_fffc".U(WLEN.W))
  pc := io.nextPC

  io.imem.en := true.B
  io.imem.addr := pc.asUInt()

  io.pc := pc
  io.inst := io.imem.rdata(31, 0)
}
