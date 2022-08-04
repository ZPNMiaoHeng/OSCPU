import chisel3._
import chisel3.util._
import chisel3.experimental.FlatIO
import Instructions._

/**
  * IDU module is output instruction parameter and instruction type
  * 
  * Function : Input a 64-bits isntruction , IDU module can find out whar instruction type.
  *     And output parameter and signal according to the instruction typr.
  * Extend: find input instruction types ,and then output  
  */

class Decode extends Module {
  val io = IO(new Bundle {  
    val inst = Input(UInt(32.W))
    val rdData = Input(UInt(64.W))
    val pc = Input(UInt(32.W))

    val Branch = Output(UInt(3.W))  //!
  })
  val aluIO = FlatIO(new AluIO)
  val memCtr = FlatIO(new MemCtr)

  val regs = Module(new RegFile)
  val imm  = Module(new ImmGen)
  val con  = Module(new ContrGen)
  
  regs.io.rs1En := con.io.rAddr1En
  regs.io.rs2En := con.io.rAddr2En
  regs.io.rs1Addr := con.io.rAddr1
  regs.io.rs2Addr := con.io.rAddr2
  regs.io.rdAddr := con.io.wAddr
  regs.io.rdEn := con.io.RegWr
  regs.io.rdData := io.rdData

  imm.io.inst := io.inst
  imm.io.immOp := con.io.immOp
  con.io.inst := io.inst

  io.Branch   := con.io.Branch

  memCtr <> con.io.memCtr
  aluIO.ctrl <> con.io.aluCtr
  aluIO.data.rData1 := regs.io.rs1Data
  aluIO.data.rData2 := regs.io.rs2Data
  aluIO.data.imm := imm.io.imm

}
