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
    val rs1_addr = Output(UInt(5.W))
    val rs1_en = Output(Bool())
    val rs2_addr = Output(UInt(5.W))
    val rs2_en = Output(Bool())
    val rd_addr = Output(UInt(5.W))
    val rd_en = Output(Bool())
    val opcode = Output(UInt(8.W))
    val imm = Output(UInt(64.W))
/*    
    val Inst   = Input(UInt(32.W))
    val WData  = Input(UInt(64.W))
    val PC     = Input(UInt(32.W))

    val Branch = Output(UInt(3.W))
    */
  })
  /*
  val aluIO = FlatIO(new AluIO)
  val memCtr = FlatIO(new MemCtr)

  val regs = Module(new RegFile)
  val imm  = Module(new ImmGen)
  val con  = Module(new ContrGen)
  
//  regs.io.clk      := clock
//  regs.io.reset    := reset
  regs.io.rAddr1En := con.io.rAddr1En
  regs.io.rAddr2En := con.io.rAddr2En
  regs.io.RAddr1   := con.io.rAddr1
  regs.io.RAddr2   := con.io.rAddr2
  regs.io.WAddr    := con.io.wAddr
  regs.io.RegWr    := con.io.RegWr
  regs.io.WData    := io.WData

  imm.io.inst    := io.Inst
  imm.io.immOp   := con.io.immOp
  con.io.inst    := io.Inst

  io.Branch   := con.io.Branch

  memCtr <> con.io.memCtr
  aluIO.ctrl <> con.io.aluCtr
  aluIO.data.rData1 := regs.io.RData1
  aluIO.data.rData2 := regs.io.RData2
  aluIO.data.imm := imm.io.imm

*/
    

  val inst = io.inst
  val opcode = WireInit(UInt(8.W), 0.U)
  val imm_i = Cat(Fill(53, inst(31)), inst(30, 20))

  // Only example here, use your own control flow!
  when (inst === ADDI) {
    opcode := 1.U
  }

  io.rs1_addr := inst(19, 15)
  io.rs2_addr := inst(24, 20)
  io.rd_addr := inst(11, 7)
  
  io.rs1_en := false.B
  io.rs2_en := false.B
  io.rd_en := false.B

  when (inst === ADDI) {
    io.rs1_en := true.B
    io.rs2_en := false.B
    io.rd_en := true.B
  }
  
  io.opcode := opcode
  io.imm := imm_i

}
