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
//    val opcode = Output(UInt(5.W))
    val imm = Output(UInt(64.W))

    val ctrl = new AluCtr
    val memCtr = new MemCtr
  })
  
  val imm  = Module(new ImmGen)
  val con  = Module(new ContrGen)
  imm.io.inst := io.inst
  imm.io.immOp := con.io.immOp

  con.io.inst := io.inst
  io.memCtr <> con.io.memCtr
  io.ctrl <> con.io.aluCtr
//  io.aluIO.ctrl <> con.io.aluCtr
  io.imm := imm.io.imm

  io.rs1_addr := con.io.regCtrl.rs2Addr     //inst(19, 15)
  io.rs2_addr := con.io.regCtrl.rs1Addr     //inst(24, 20)
  io.rd_addr := con.io.regCtrl.rdAddr       //inst(11, 7)
  
  io.rs1_en := con.io.regCtrl.rs1En         //false.B
  io.rs2_en := con.io.regCtrl.rs2En         //false.B
  io.rd_en := con.io.regCtrl.rdEn           //false.B

//  io.opcode := con.io.aluCtr.aluOp

}
