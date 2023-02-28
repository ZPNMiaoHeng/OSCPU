import chisel3._
import chisel3.util._
import Constant._

class BUS_R extends Bundle {
  val valid = Bool()
  val pc = UInt(WLEN.W)
  val inst = UInt(WLEN.W)
  val typeL = Bool()

  val aluA = UInt(1.W)
  val aluB = UInt(2.W)
  val aluOp = UInt(4.W)
  val branch = UInt(3.W)
  val memtoReg = UInt(2.W)
  val memWr = UInt(1.W)
  val memOp = UInt(3.W)
  val memAddr = UInt(32.W)     // 存入Mem中地址
  val rdEn = Bool()
  val rdAddr = UInt(5.W)
  val rs1Data = UInt(XLEN.W)
  val rs2Data = UInt(XLEN.W)
  val imm = UInt(XLEN.W)

  val pcSrc = UInt(2.W)
  val nextPC = UInt(WLEN.W)
  val aluRes = UInt(XLEN.W)
  val memData = UInt(XLEN.W)
  
  val csrOp = UInt(4.W)               //* +
  val intr = Bool()

//  val bp_taken  = Bool()
//  val bp_targer = UInt(32.W)

  def flush() : Unit = {
    valid    := false.B
    pc       := 0.U
    inst     := 0.U   //"h00000013".U   // nop
    typeL    := false.B

    aluA     := 0.U
    aluB     := "b11".U
    aluOp    := 0.U
    
    branch   := 0.U
    memtoReg := 0.U
    memWr    := 0.U
    memOp    := 0.U
    memAddr  := 0.U

    rdEn     := 0.U
    rdAddr   := 0.U
//    rdData   := 0.U
    rs1Data  := 0.U
    rs2Data  := 0.U
    imm      := 0.U

    pcSrc    := 0.U
    nextPC   := 0.U
    aluRes   := 0.U
    memData  := 0.U

    csrOp := 0.U
    intr := false.B

//    bp_taken  := false.B
//    bp_targer := 0.U
  }
}
//  val ready = true.B
//  val fire = io.in.valid && ready

class PipelineReg extends Module {
  val io = IO(new Bundle {
    val in      = Input(new BUS_R)
    val out     = Output(new BUS_R)
    val flush   = Input(Bool())
    val stall   = Input(Bool())
//    val ready = Input(Bool())
    val instChange = Output(Bool())
  })

  val reg = RegInit(0.U.asTypeOf(new BUS_R))
//* bypass: flush > stall
  when (/*fire &&*/ io.flush && !io.stall) {
    reg.flush()
  } .elsewhen (!io.stall) {
    reg := io.in
  }

  io.out := reg

  val pcT = Reg(UInt(WLEN.W))
  pcT := io.in.pc
  io.instChange := Mux(pcT =/= io.in.pc, true.B, false.B)
}

