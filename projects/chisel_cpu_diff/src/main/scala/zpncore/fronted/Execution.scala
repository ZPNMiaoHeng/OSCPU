import chisel3._
import chisel3.util._
import Constant._
import utils._

class Execution extends Module {
    val io = IO(new Bundle {
        val in = Input(new BUS_R)

        val out = Output(new BUS_R)
        val exeRdData = Output(UInt(XLEN.W)) 
        val bubbleEx = Output(Bool())
        val takenValid = Output(Bool())
        val takenMiss = Output(Bool())
        val takenPC = Output(UInt(WLEN.W))
        val exeX1En = Output(Bool())
        val exeAluRes = Output(UInt(64.W))

        val exc = Input(Bool())
        val csrOp = Input(UInt(4.W))
        val mepc = Input(UInt(64.W))
        val mtvec = Input(UInt(64.W))
        val time_int = Input(Bool())
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

    nextPC.io.exc := io.exc
    nextPC.io.csrOp := io.csrOp
    nextPC.io.mepc := io.mepc
    nextPC.io.mtvec := io.mtvec
    nextPC.io.time_int := io.time_int
//----------------------------------------------------------------
  val exeValid = io.in.valid
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
  val exeRs1Data = io.in.rs1Data
  val exeRs2Data = io.in.rs2Data
  val exeImm = io.in.imm
  val exePCSrc = nextPC.io.pcSrc
  val exeNextPC = nextPC.io.nextPC
  val exeAluRes = alu.io.aluRes
  val exeCsrOp = io.in.csrOp
  val exeTakenPre = io.in.takenPre
  val exeTakenPrePC = io.in.takenPrePC

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
  io.out.memAddr  := 0.U
  io.out.rdEn     := exeRdEn
  io.out.rdAddr   := exeRdAddr
  io.out.rs1Data  := exeRs1Data
  io.out.rs2Data  := exeRs2Data
  io.out.imm      := exeImm
  io.out.pcSrc    := exePCSrc
  io.out.nextPC   := exeNextPC
  io.out.aluRes   := exeAluRes
  io.out.memData  := 0.U
  io.out.csrOp    := exeCsrOp
  io.out.takenPre := exeTakenPre
  io.out.takenPrePC := exeTakenPrePC

  io.exeRdData := exeAluRes  
  io.bubbleEx := io.in.typeL
  io.takenValid := exeBranch(2).asBool  // bxx
  io.takenMiss := Mux(exeTakenPre, exeTakenPrePC =/= exeNextPC, exePCSrc =/= 0.U)  // 若预测跳转，对比计算后的PC；若预测不跳转。看是否跳转；
  io.takenPC := exePC
  
  io.exeX1En := io.in.rdEn && (io.in.rdAddr === 1.U)
  io.exeAluRes := alu.io.aluRes
}