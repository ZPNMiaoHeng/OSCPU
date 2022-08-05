import chisel3._
import chisel3.util._
import Instructions._

class Decode extends Module {
  val io = IO(new Bundle {
    val inst = Input(UInt(32.W))

    val rs1_addr = Output(UInt(5.W))
    val rs1_en = Output(Bool())
    val rs2_addr = Output(UInt(5.W))
    val rs2_en = Output(Bool())
    val rd_addr = Output(UInt(5.W))
    val rd_en = Output(Bool())
    val opcode = Output(UInt(5.W))
    val imm = Output(UInt(64.W))
  })
  
  val imm  = Module(new ImmGen)
  val con  = Module(new ContrGen)
  imm.io.inst := io.inst
  imm.io.immOp := con.io.immOp

  con.io.inst := io.inst
//  io.aluIO.ctrl <> con.io.aluCtr
  io.imm := imm.io.imm

  val inst = io.inst
  val opcode = WireInit(UInt(8.W), 0.U)

  // Only example here, use your own control flow!
/*  
  when (inst === ADDI) {
    opcode := 1.U
  }
*/
  io.rs1_addr := con.io.regCtrl.rs2Addr//inst(19, 15)
  io.rs2_addr := con.io.regCtrl.rs1Addr//inst(24, 20)
  io.rd_addr := con.io.regCtrl.rdAddr//inst(11, 7)
  
  io.rs1_en := con.io.regCtrl.rs1En//false.B
  io.rs2_en := con.io.regCtrl.rs2En//false.B
  io.rd_en := con.io.regCtrl.rdEn //false.B
/*
  when (inst === ADDI) {
    io.rs1_en := true.B
    io.rs2_en := false.B
    io.rd_en := true.B
  }
  */
  io.opcode := con.io.aluCtr.aluOp

}
