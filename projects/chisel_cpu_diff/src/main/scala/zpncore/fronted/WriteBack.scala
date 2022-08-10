import chisel3._
import chisel3.util._
import Constant._
import utils._

class WriteBack extends Module {
    val io = IO(new Bundle {
        val in        = Input(new BUS_R)

        val pc        = Output(UInt(32.W))
        val inst      = Output(UInt(32.W))
     
        val rdEn       = Output(Bool())
        val rdAddr     = Output(UInt(5.W))
        val rdData     = Output(UInt(64.W))
     
        val wbRdEn = Output(Bool())
        val wbRdAddr  = Output(UInt(5.W))
        val wbRdData = Output(UInt(64.W))
     
        val ready_cmt = Output(Bool())
    })

  val resW = SignExt(io.in.aluRes(31,0), 64)

  val rdData = LookupTreeDefault(io.in.memtoReg, 0.U, List(
      ("b00".U) -> io.in.aluRes,
      ("b01".U) -> io.in.memData,
      ("b10".U) -> resW
  ))

  io.pc := io.in.pc
  io.inst := io.in.inst

  io.rdEn := io.in.rdEn
  io.rdAddr := io.in.rdAddr
  io.rdData := rdData
  io.ready_cmt := io.in.inst =/= 0.U && io.in.valid

  io.wbRdEn := io.in.rdEn
  io.wbRdAddr := io.in.rdAddr
  io.wbRdData := io.in.aluRes

}
  