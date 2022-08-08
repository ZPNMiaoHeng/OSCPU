import chisel3._
import chisel3.util._
import Constant._


class BUS_R extends Bundle {
  val valid = Bool()
  val pc = UInt(32.W)
  val inst = UInt(32.W)
  val aluA = UInt(1.W)
  val aluB = UInt(2.W)
  val aluOp = UInt(4.W)
  val branch = UInt(3.W)
  val memtoReg = UInt(2.W)
  val memWr = UInt(1.W)
  val memOp = UInt(3.W)
  val rs1Data = UInt(32.W)
  val rs2Data = UInt(32.W)
  val imm = UInt(32.W)
//  val nextPC = UInt(32.W)
  val aluRes = UInt(32.W)
  val wData = UInt(32.W)

//  val bp_taken  = Bool()
//  val bp_targer = UInt(32.W)

  def flush() : Unit = {
    valid    := false.B
    pc       := 0.U
    inst     := 0.U
    aluA     := 0.U
    aluB     := 0.U
    aluOp    := 0.U
    branch   := 0.U
    memtoReg := 0.U
    memWr    := 0.U
    memOp    := 0.U
    rs1Data  := 0.U
    rs2Data  := 0.U
    imm      := 0.U
//    nextPC   := 0.U
    aluRes   := 0.U
    wData    := 0.U
//    bp_taken  := false.B
//    bp_targer := 0.U
  }
}

class PipelineReg extends Module {
  val io = IO(new Bundle {
    val in      = Input(new BUS_R)
    val out     = Output(new BUS_R)
    val flush   = Input(Bool())
    val stall   = Input(Bool())
  })

  val reg = RegInit(0.U.asTypeOf(new BUS_R))

  when (io.flush && !io.stall) {
    reg.flush()
  } .elsewhen (!io.stall) {
    reg := io.in
  }

  io.out := reg
}

