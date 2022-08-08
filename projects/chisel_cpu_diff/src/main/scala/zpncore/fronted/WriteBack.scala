import chisel3._
import chisel3.util._
import Constant._
import utils._

class WriteBack extends Module {
    val io = IO(new Bundle {
        val memtoReg = Input(UInt(2.W))
        val aluRes = Input(UInt(XLEN.W))
        val memData = Input(UInt(XLEN.W))

        val wData = Output(UInt(XLEN.W))
    })

  val resW = SignExt(io.aluRes(31,0), 64)
  io.wData := LookupTreeDefault(io.memtoReg, 0.U, List(
      ("b00".U) -> io.aluRes,
      ("b01".U) -> io.memData,
      ("b10".U) -> resW
  ))

}
  