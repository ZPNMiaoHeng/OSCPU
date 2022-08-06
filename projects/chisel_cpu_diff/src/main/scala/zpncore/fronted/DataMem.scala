import chisel3._
import chisel3.util._
import Constant._
import utils._
/**
  ** 内存使用第三期环境，访存指令需要进行8字节对齐处理
  ** 
  */

class DataMem extends Module {
  val io = IO(new Bundle {
    val Addr    = Input(UInt(64.W))
    val DataIn  = Input(UInt(64.W))

    val memCtr = Flipped(new MemCtr)
    val dmem = new RamIO
    val rdData = Output(UInt(64.W))
  })

  io.dmem.en := !(io.Addr < "h8000_0000".U || io.Addr > "h8800_0000".U) &&
       ((io.memCtr.MemtoReg === "b01".U) || (io.memCtr.MemWr === 1.U))
  io.dmem.addr := io.Addr
  io.dmem.wen := !(io.Addr < "h8000_0000".U || io.Addr > "h8800_0000".U) && (io.memCtr.MemWr === 1.U)
  val alignBits = io.Addr % 8.U
  io.dmem.wdata := io.DataIn << alignBits * 8.U
  io.dmem.wmask := LookupTreeDefault(io.memCtr.MemOP, 0.U, List(
    "b000".U -> LookupTreeDefault(alignBits, "h0000_0000_0000_00ff".U, List(
      1.U -> "h0000_0000_0000_ff00".U,
      2.U -> "h0000_0000_00ff_0000".U,
      3.U -> "h0000_0000_ff00_0000".U,
      4.U -> "h0000_00ff_0000_0000".U,
      5.U -> "h0000_ff00_0000_0000".U,
      6.U -> "h00ff_0000_0000_0000".U,
      7.U -> "hff00_0000_0000_0000".U
    )),
    "b001".U -> LookupTreeDefault(alignBits,  "h0000_0000_0000_ffff".U, List(
      2.U -> "h0000_0000_ffff_0000".U,
      4.U -> "h0000_ffff_0000_0000".U,
      6.U -> "hffff_0000_0000_0000".U,
    )),
    "b010".U -> Mux(alignBits === 0.U, "h0000_0000_ffff_ffff".U, "hffff_ffff_0000_0000".U),
    "b011".U -> "hffff_ffff_ffff_ffff".U
  ))

  val rdata = io.dmem.rdata >> alignBits * 8.U
  val rData = LookupTreeDefault(io.memCtr.MemOP, 0.U, List(
    "b000".U -> SignExt(rdata(7 , 0), XLEN),
    "b001".U -> SignExt(rdata(15, 0), XLEN),
    "b010".U -> SignExt(rdata(31, 0), XLEN), 
    "b011".U -> rdata,
    "b100".U -> ZeroExt(rdata(7 , 0), XLEN),
    "b101".U -> ZeroExt(rdata(15, 0), XLEN),
    "b110".U -> ZeroExt(rdata(31, 0), XLEN)
  ))
  io.rdData := Mux(io.memCtr.MemWr === 1.U, 0.U, rData)
}
