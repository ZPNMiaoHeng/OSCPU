import chisel3._
import chisel3.util._
// import Instructions._
import Constant._
import utils._

class preDebug extends Module {
  val io = IO(new Bundle {
    val exeBranch = Input(UInt(3.W))
    val takenMiss = Input(Bool())
    val coreEnd = Input(Bool())
    val IFDone = Input(Bool())
    val memDone = Input(Bool())
  })

  val bjp = RegInit(VecInit(Seq.fill(8)(0.U(8.W))))
  val bjpMiss = RegInit(VecInit(Seq.fill(8)(0.U(8.W))))
  // bjp(0) := Mux(io.exeBranch === "b001".U, )
when(io.IFDone && io.memDone) {
  when (io.exeBranch === "b001".U) {
    bjp(0) := bjp(0) + 1.U
    when(io.takenMiss) {
      bjpMiss(0) := bjpMiss(0) + 1.U
    }
  } .elsewhen (io.exeBranch === "b010".U ){
    bjp(1) := bjp(1) + 1.U
    when(io.takenMiss) {
      bjpMiss(1) := bjpMiss(1) + 1.U
    }
  } .elsewhen (io.exeBranch === "b100".U ){
    bjp(2) := bjp(2) + 1.U
    when(io.takenMiss) {
      bjpMiss(2) := bjpMiss(2) + 1.U
    }
  } .elsewhen (io.exeBranch === "b101".U ){
    bjp(3) := bjp(3) + 1.U
    when(io.takenMiss) {
      bjpMiss(3) := bjpMiss(3) + 1.U
    }
  } .elsewhen (io.exeBranch === "b110".U ){
    bjp(4) := bjp(4) + 1.U
    when(io.takenMiss) {
      bjpMiss(4) := bjpMiss(4) + 1.U
    }
  } .elsewhen (io.exeBranch === "b111".U ){
    bjp(5) := bjp(5) + 1.U
    when(io.takenMiss) {
      bjpMiss(5) := bjpMiss(5) + 1.U
    }
  }
}

  val jal  = bjpMiss(0) / bjp(0)
  val jalr = bjpMiss(1) / bjp(1)
  val beq  = bjpMiss(2) / bjp(2)
  val bne  = bjpMiss(3) / bjp(3)
  val blt  = bjpMiss(4) / bjp(4)
  val bge  = bjpMiss(5) / bjp(5)

  when(io.coreEnd && io.IFDone && io.memDone) {
    printf("Name:\tjal\tjalr\tbeq\tbne\tblt\tbge\n")
    printf("ALL:\t%d\t%d\t%d\t%d\t%d\t%d\n", bjp(0), bjp(1), bjp(2), bjp(3), bjp(4), bjp(5))
    printf("Miss:\t%d\t%d\t%d\t%d\t%d\t%d\n", bjpMiss(0), bjpMiss(1), bjpMiss(2), bjpMiss(3), bjpMiss(4), bjpMiss(5))
    printf("Res:\t%d\t%d\t%d\t%d\t%d\t%d\n", jal, jalr, beq, bne, blt, bge)
  }
}