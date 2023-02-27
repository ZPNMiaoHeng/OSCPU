import chisel3._
import chisel3.util._
import Constant._
import utils._

class WriteBack extends Module {
    val io = IO(new Bundle {
        val in = Input(new BUS_R)
        val IFDone = Input(Bool())

        val pc   = Output(UInt(32.W))
        val inst = Output(UInt(32.W))
     
        val rdEn   = Output(Bool())
        val rdAddr = Output(UInt(5.W))
        val rdData = Output(UInt(64.W))
     
        val wbRdEn   = Output(Bool())
        val wbRdAddr = Output(UInt(5.W))
        val wbRdData = Output(UInt(64.W))
     
        val ready_cmt = Output(Bool())
        val csrOp_WB = Output(UInt(4.W))

        val mepc = Output(UInt(64.W))
        val mtvec = Output(UInt(64.W))
        val csrOp = Output(UInt(4.W))

        val cmp_ren   = Input(Bool())
        val cmp_wen   = Input(Bool())
        val cmp_addr  = Input(UInt(64.W))
        val cmp_wdata = Input(UInt(64.W))
        val cmp_rdata = Output(UInt(64.W))

        val clintEn = Output(Bool())
    })

  val csr = Module(new CSR)
  csr.io.pc := io.in.pc
  csr.io.inst := io.in.inst
  csr.io.IFDone := io.IFDone
  csr.io.csrOp := io.in.csrOp
  csr.io.rs1Data := io.in.rs1Data
  csr.io.rAddr := io.in.inst(31, 20)    //io.csrRAddr
  io.clintEn := csr.io.clintEn

  csr.io.cmp_ren := io.cmp_ren
  csr.io.cmp_wen := io.cmp_wen
  csr.io.cmp_addr := io.cmp_addr
  csr.io.cmp_wdata := io.cmp_wdata

  io.cmp_rdata := csr.io.cmp_rdata
  io.clintEn := csr.io.clintEn

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
  io.rdData := Mux(io.in.csrOp === 0.U, rdData, csr.io.rData)
  io.ready_cmt := io.in.inst =/= 0.U && io.in.valid

  io.wbRdEn := io.in.rdEn
  io.wbRdAddr := io.in.rdAddr
  io.wbRdData := Mux(io.in.csrOp === 0.U, rdData, csr.io.rData)

  io.csrOp := io.in.csrOp

  io.mepc    := csr.io.mepc
  io.mtvec   := csr.io.mtvec
  io.csrOp_WB := csr.io.csrOp_WB

}
  