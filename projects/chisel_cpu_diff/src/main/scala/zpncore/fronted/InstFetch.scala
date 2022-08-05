import chisel3._
import chisel3.util._

class InstFetch extends Module {
  val io = IO(new Bundle {
    val imem = new RomIO
    val nextPC = Input(UInt(32.W))
    val pc = Output(UInt(32.W))
    val inst = Output(UInt(32.W))

  })

//  val pc_en = RegInit(false.B)
//  pc_en := true.B

  val pc = RegInit("h7fff_fffc".U(32.W))
//  val pc = RegInit("h8000_0000".U(32.W))
  pc := io.nextPC

  io.imem.en := true.B
  io.imem.addr := pc.asUInt()

  io.pc := pc
  io.inst := io.imem.rdata(31, 0)
}
