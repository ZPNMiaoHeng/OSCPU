import chisel3._
import chisel3.util._
import Constant._
import utils._
/**
  * biomodal predictor
  *   size is 2KB;
  *   choose is 13bits, pc[15 : 3];
  * ****************************************
  * First:实现简单静态分支预测-向后跳转
  */

  class bht extends Module {
    val io = IO(new Bundle {
      val pc = Input(UInt(32.W)) //Current PC

      val jal = Input(Bool())
      val jalr = Input(Bool())
      val bxx = Input(Bool())
      val imm = Input(UInt(XLEN.W))
      val rs1Addr = Input(UInt(5.W))

      val rs1Data = Input(UInt(64.W))
      val rs1x1Data = Input(UInt(64.W))

      val takenPre = Output(Bool())
      val takenPrePC = Output(UInt(32.W))
    })

    val rs1x0 = (io.rs1Addr === 0.U(5.W))
    val rs1x1 = (io.rs1Addr === 1.U(5.W))
    val rs1xn = !(rs1x0 | rs1x1)
    val op1 = Mux(io.bxx | io.jal, io.pc,
                Mux(io.jalr & rs1x0, 0.U(64.W),
                Mux(io.jalr & rs1x1, io.rs1x1Data, io.rs1Data)))

    val op2 = io.imm

    io.takenPrePC := op1 + op2
    io.takenPre := io.jal | io.jalr | (io.bxx & io.imm(63)) //jal、jalr、以及向后一定跳转

/*     val T = WireInit(false.B)
    val NT = WireInit(false.B)
    val prd = WireInit(0.U(13.W))
    prd := io.pc(15, 3)
    
    val SNTaken :: WNTaken :: WTAken :: STaken :: Nil = Enum(4)
    val state = RegInit(STaken)
    state :=  */
  }