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
//*    val inst = Input(UInt(WLEN.W))
    val rdData = Input(UInt(XLEN.W))

//*    val branch = Output(UInt(3.W)) 
//*    val aluIO = new AluIO
//*    val memCtr = new MemCtr

    val in = Input(new BUS_R)
    val out = Output(new BUS_R)
  })

  val regs = Module(new RegFile)
  val imm  = Module(new ImmGen)
  val con  = Module(new ContrGen)

  regs.io.ctrl <> con.io.regCtrl
  regs.io.rdData := io.rdData

  imm.io.inst := io.in.inst
  imm.io.immOp := con.io.immOp
  con.io.inst := io.in.inst

//*  io.aluIO.ctrl <> con.io.aluCtr
//*  io.aluIO.data.rData1 := regs.io.rs1Data
//*  io.aluIO.data.rData2 := regs.io.rs2Data
//*  io.aluIO.data.imm := imm.io.imm

//*  io.memCtr <> con.io.memCtr
//*  io.branch := con.io.branch

  val idValid = true.B // io.in.valid
  val idPC = io.in.pc
  val idInst = io.in.inst
  val idAluA = con.io.aluCtr.aluA
  val idAluB = con.io.aluCtr.aluB
  val idAluOp = con.io.aluCtr.aluOp
  val idBranch = con.io.branch
  val idMemtoReg = con.io.aluCtr.memtoReg
  val idMemWr = con.io.aluCtr.memWr
  val idMemOp = con.io.aluCtr.memOp
  val idRs1Data = regs.io.rs1Data
  val idRs2Data = regs.io.rs2Data
  val idImm = imm.io.imm

//----------------------------------------------------------------
  io.out.valid    := idValid
  io.out.pc       := idPC
  io.out.inst     := idInst
  io.out.aluA     := idAluA
  io.out.aluB     := idAluB
  io.out.aluOp    := idAluOp
  io.out.branch   := idBranch
  io.out.memtoReg := idMemtoReg
  io.out.memWr    := idMemWr
  io.out.memOp    := idMemOp
  io.out.rs1Data  := idRs1Data
  io.out.rs2Data  := idRs2Data
  io.out.imm      := idImm
//  io.out.nextPC   := 0.U
  io.out.aluRes   := 0.U
  io.out.wData    := 0.U
}
