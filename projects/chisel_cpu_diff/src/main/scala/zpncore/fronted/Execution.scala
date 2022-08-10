import chisel3._
import chisel3.util._
import Constant._

class Execution extends Module {
    val io = IO(new Bundle {
        val in = Input(new BUS_R)
        val out = Output(new BUS_R)

//        val pcSrc = Output(UInt(2.W))
//        val nextPC = Output(UInt(WLEN.W))
        
        val exeRdEn = Output(Bool())
        val exeRdAddr = Output(UInt(WLEN.W))
        val exeRdData = Output(UInt(XLEN.W))
        
        val bubbleEx = Output(Bool())
    })
    val alu = Module(new ALU)
    val nextPC = Module(new NextPC)
    alu.aluIO.ctrl.aluA := io.in.aluA
    alu.aluIO.ctrl.aluB := io.in.aluB
    alu.aluIO.ctrl.aluOp := io.in.aluOp
    alu.aluIO.data.rData1 := io.in.rs1Data
    alu.aluIO.data.rData2 := io.in.rs2Data
    alu.aluIO.data.imm := io.in.imm
    alu.io.memtoReg := io.in.memtoReg
    alu.io.pc := io.in.pc

    nextPC.io.pc := io.in.pc
    nextPC.io.imm := io.in.imm
    nextPC.io.rs1Data := io.in.rs1Data
    nextPC.io.branch := io.in.branch
    nextPC.io.less := alu.io.less
    nextPC.io.zero := alu.io.zero

    val pcSrc = nextPC.io.pcSrc
//----------------------------------------------------------------
  val exeValid = true.B // io.in.valid
  val exePC = io.in.pc
  val exeInst = io.in.inst
  val exeTypeL = io.in.typeL
  val exeAluA = io.in.aluA
  val exeAluB = io.in.aluB
  val exeAluOp = io.in.aluOp
  val exeBranch = io.in.branch
  val exeMemtoReg = io.in.memtoReg
  val exeMemWr = io.in.memWr
  val exeMemOp = io.in.memOp
  val exeRdEn   = io.in.rdEn
  val exeRdAddr = io.in.rdAddr
  val exeRdData = 0.U
  val exeRs1Data = io.in.rs1Data
  val exeRs2Data = io.in.rs2Data
  val exeImm = io.in.imm
  val exePCSrc = pcSrc
  val exeNextPC = nextPC.io.nextPC
  val exeAluRes = alu.io.aluRes

//----------------------------------------------------------------
  io.out.valid    := exeValid
  io.out.pc       := exePC
  io.out.inst     := exeInst
  io.out.typeL    := exeTypeL
  io.out.aluA     := exeAluA
  io.out.aluB     := exeAluB
  io.out.aluOp    := exeAluOp
  io.out.branch   := exeBranch
  io.out.memtoReg := exeMemtoReg
  io.out.memWr    := exeMemWr
  io.out.memOp    := exeMemOp
  io.out.rdEn     := exeRdEn
  io.out.rdAddr   := exeRdAddr
  io.out.rdData   := exeRdData
  io.out.rs1Data  := exeRs1Data
  io.out.rs2Data  := exeRs2Data
  io.out.imm      := exeImm
  io.out.pcSrc    := exePCSrc
  io.out.nextPC   := exeNextPC
  io.out.aluRes   := exeAluRes
  io.out.memData    := 0.U

  io.exeRdEn := io.in.rdEn
  io.exeRdAddr := exeRdAddr
  io.exeRdData := exeAluRes
  
//  io.pcSrc := pcSrc
//  io.nextPC := nextPC.io.nextPC
  io.bubbleEx := io.in.typeL
}