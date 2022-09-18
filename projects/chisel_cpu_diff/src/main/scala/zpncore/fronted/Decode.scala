import chisel3._
import chisel3.util._
import Constant._
import utils._
/**
  * IDU module is output instruction parameter and instruction type
  * 
  * Function : Input a 64-bits isntruction , IDU module can find out whar instruction type.
  *     And output parameter and signal according to the instruction typr.
  * Extend: find input instruction types ,and then output  
  */

class Decode extends Module {
  val io = IO(new Bundle {  
    val rdEn = Input(Bool())               // 流水线结束才会写回
    val rdAddr = Input(UInt(5.W))
    val rdData = Input(UInt(XLEN.W))

    val in = Input(new BUS_R)

    val exeRdEn = Input(Bool())
    val exeRdAddr = Input(UInt(5.W))
    val exeRdData = Input(UInt(XLEN.W))
    val memRdEn = Input(Bool())
    val memRdAddr = Input(UInt(5.W))
    val memRdData = Input(UInt(XLEN.W))
    val wbRdEn = Input(Bool())
    val wbRdAddr = Input(UInt(5.W))
    val wbRdData = Input(UInt(XLEN.W))

    val bubbleId = Output(Bool())
    val out = Output(new BUS_R)
  })

  val regs = Module(new RegFile)
  val imm  = Module(new ImmGen)
  val con  = Module(new ContrGen)

  regs.io.ctrl <> con.io.regCtrl
  regs.io.rdEn := io.rdEn
  regs.io.rdAddr := io.rdAddr
  regs.io.rdData := io.rdData

  imm.io.inst := io.in.inst
  imm.io.immOp := con.io.immOp
  con.io.inst := io.in.inst

//* bypass control signals

  val rs1Addr = Mux(con.io.regCtrl.rs1En, con.io.regCtrl.rs1Addr, 0.U)
  val rs2Addr = Mux(con.io.regCtrl.rs2En, con.io.regCtrl.rs2Addr, 0.U)
  val rdRs1HitEx = io.exeRdEn && (rs1Addr === io.exeRdAddr) && (rs1Addr =/= 0.U)
  val rdRs1HitMem = io.memRdEn && (rs1Addr === io.memRdAddr) && (rs1Addr =/= 0.U)
  val rdRs1HitWb = io.wbRdEn && (rs1Addr === io.wbRdAddr) && (rs1Addr =/= 0.U)
  
  val rdRs2HitEx = io.exeRdEn && (rs2Addr === io.exeRdAddr) && (rs2Addr =/= 0.U)
  val rdRs2HitMem = io.memRdEn && (rs2Addr === io.memRdAddr) && (rs2Addr =/= 0.U)
  val rdRs2HitWb = io.wbRdEn && (rs2Addr === io.wbRdAddr) && (rs2Addr =/= 0.U)
//* bypass：EX > MEM > WB
  val rs1Data = Mux(con.io.regCtrl.rs1En, 
    Mux(rdRs1HitEx, io.exeRdData, 
    Mux(rdRs1HitMem, io.memRdData,
    Mux(rdRs1HitWb, io.wbRdData, regs.io.rs1Data))) ,0.U )
  
  val rs2Data = Mux(con.io.regCtrl.rs2En, 
    Mux(rdRs2HitEx, io.exeRdData, 
    Mux(rdRs2HitMem, io.memRdData,
    Mux(rdRs2HitWb, io.wbRdData, regs.io.rs2Data))) ,0.U )


  val idValid = io.in.valid
  val idPC = io.in.pc
  val idInst = io.in.inst
  
  val idTypeL = con.io.typeL
  val idAluA = con.io.aluCtr.aluA
  val idAluB = con.io.aluCtr.aluB
  val idAluOp = con.io.aluCtr.aluOp
  val idBranch = con.io.branch
  val idMemtoReg = con.io.memCtr.memtoReg
  val idMemWr = con.io.memCtr.memWr
  val idMemOp = con.io.memCtr.memOP
  val idRdEn   = con.io.rdEn
  val idRdAddr = con.io.rdAddr
  val idRs1Data = rs1Data
  val idRs2Data = rs2Data
  val idImm = imm.io.imm

//----------------------------------------------------------------
  io.out.valid    := idValid
  io.out.pc       := idPC
  io.out.inst     := idInst
  io.out.typeL    := idTypeL
  io.out.aluA     := idAluA
  io.out.aluB     := idAluB
  io.out.aluOp    := idAluOp
  io.out.branch   := idBranch
  io.out.memtoReg := idMemtoReg
  io.out.memWr    := idMemWr
  io.out.memOp    := idMemOp
  io.out.rdEn     := idRdEn
  io.out.rdAddr   := idRdAddr
  io.out.rs1Data  := idRs1Data
  io.out.rs2Data  := idRs2Data
  io.out.imm      := idImm
  io.out.pcSrc    := 0.U
  io.out.nextPC   := 0.U
  io.out.aluRes   := 0.U
  io.out.memData  := 0.U

  io.bubbleId := (rdRs1HitEx || rdRs2HitEx)
}
