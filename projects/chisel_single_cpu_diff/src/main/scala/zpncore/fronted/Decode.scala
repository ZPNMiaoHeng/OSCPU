import chisel3._
import chisel3.util._
import Instructions._
import Constant._

/**
  * IDU module is output instruction parameter and instruction type
  * 
  * Function : Input a 64-bits isntruction , IDU module can find out whar instruction type.
  *     And output parameter and signal according to the instruction typr.
  * Extend: find input instruction types ,and then output  
  */

class Decode extends Module {
  val io = IO(new Bundle {  
    val inst = Input(UInt(WLEN.W))
    val rdData = Input(UInt(XLEN.W))

    val Branch = Output(UInt(3.W)) 
    val aluIO = new AluIO
    val memCtr = new MemCtr
  })

  val regs = Module(new RegFile)
  val imm  = Module(new ImmGen)
  val con  = Module(new ContrGen)

  regs.io.ctrl <> con.io.regCtrl
  regs.io.rdData := io.rdData

  imm.io.inst := io.inst
  imm.io.immOp := con.io.immOp
  con.io.inst := io.inst

  io.memCtr <> con.io.memCtr
  io.aluIO.ctrl <> con.io.aluCtr
  io.aluIO.data.rData1 := regs.io.rs1Data
  io.aluIO.data.rData2 := regs.io.rs2Data
  io.aluIO.data.imm := imm.io.imm

  io.Branch   := con.io.Branch
}
