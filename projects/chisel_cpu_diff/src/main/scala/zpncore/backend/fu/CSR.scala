import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import difftest._
import Constant._

class Csr extends Module {
  val io = IO(new Bundle {
    val pc    = Input(UInt(32.W))
    val inst  = Input(UInt(32.W))
    val rs1   = Input(UInt(64.W))
    val csrOp = Input(UInt( 4.W))
    
    val rData = Output(UInt(64.W))
    
  })
  val mstatus = RegInit(UInt(64.W), "h00001800".U) // Machine Mode
  val mtvec   = RegInit(UInt(64.W), 0.U) // Machine Trap-Vector Base-Address Register
  val mepc    = RegInit(UInt(64.W), 0.U)
  val mcause  = RegInit(UInt(64.W), 0.U)

  val rs1 = io.rs1
  val rs1I = Cat(0.U(59.W), io.inst(19, 15))
  val csrType = io.inst(31, 20)

  val csrOp = io.csrOp
  val csrRW = (csrOp(4) === 0.U)
  val csrEM = (csrOp === "b1000".U) || (csrOp === "b1001".U)

  val csr = Mux(csrRW, LookupTreeDefault(csrOp, 0.U, List(
    "b0001".U -> , 
    "b0010".U -> , 
    "b0011".U -> , 
    "b0101".U -> , 
    "b0110".U -> , 
    "b0111".U -> , 
  )) ,0.U)
  
  // ECALL
  when (srcOp === "b1000".U) {
    mepc    := io.pc
    mcause  := 11.U
    mstatus := Cat(mstatus(63,13), Fill(2, 1.U), mstatus(10,8), mstatus(3), mstatus(6, 4), 0.U, mstatus(2, 0))
  }

  // MRET : 退出机器模式，MIE位置MPIE
  when (sysop === "b1001".U) {
    mstatus := Cat(mstatus(63,13), Fill(2, 0.U), mstatus(10,8), 1.U, mstatus(6, 4), mstatus(7), mstatus(2, 0))
  }


}