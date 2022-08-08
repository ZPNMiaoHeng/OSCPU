import chisel3._
import chisel3.util._
import Constant._

class Execution extends Module {
    val io = IO(new Bundle {
        val in = Input(new BUS_R)
        val out = Output(new BUS_R)
        val nextPC = Out(UInt(XLEN.W))
    })
    val alu = Module(new AlU)
    val nextPC = Module(new NextPC)

    alu.io.memtoReg := io.in.memtoReg
    alu.io.pc := io.in.pc
    nextPC.io.pc := io.in.pc
    nextPC.io.imm := io.in.imm
    nextPC.io.rs1Data := io.in.rs1Data
    nextPC.io.branch := io.in.branch
    nextPC.io.less := alu.io.less
    nextPC.io.zero := alu.io.zero

    io.nextPC := nextPC.io.nextPC
//----------------------------------------------------------------
  val exeValid = true.B // io.in.valid
  val exePC = io.in.pc
  val exeInst = io.in.inst
  val exeAluA = io.in.aluA
  val exeAluB = io.in.aluB
  val exeAluOp = io.in.aluOp
  val exeBranch = io.in.branch
  val exeMemtoReg = io.in.memtoReg
  val exeMemWr = io.in.memWr
  val exeMemOp = io.in.memOp
  val exeRs1Data = io.in.rs1Data
  val exeRs2Data = io.in.rs2Data
  val exeImm = io.in.imm
  val exeAluRes = alu.io.aluRes

//----------------------------------------------------------------
  io.out.valid    := exeValid
  io.out.pc       := exePC
  io.out.inst     := exeInst
  io.out.aluA     := exeAluA
  io.out.aluB     := exeAluB
  io.out.aluOp    := exeAluOp
  io.out.branch   := exeBranch
  io.out.memtoReg := exeMemtoReg
  io.out.memWr    := exeMemWr
  io.out.memOp    := exeMemOp
  io.out.rs1Data  := exeRs1Data
  io.out.rs2Data  := exeRs2Data
  io.out.imm      := exeImm
//  io.out.nextPC   := 
  io.out.aluRes   := exeAluRes
  io.out.wData    := 0.U
}