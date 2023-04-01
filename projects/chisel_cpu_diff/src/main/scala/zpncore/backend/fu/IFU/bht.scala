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
//      val valid = Input(Bool())
      val fire = Input(Bool())
      val pc = Input(UInt(32.W)) //Current PC

      val jal = Input(Bool())
      val jalr = Input(Bool())
      val bxx = Input(Bool())
      val imm = Input(UInt(XLEN.W))
      val rs1Addr = Input(UInt(5.W))

      val rs1Data = Input(UInt(64.W))
      val rs1x1Data = Input(UInt(64.W))

      val takenValid = Input(Bool())
      val takenMiss = Input(Bool())
//      val nextPC = Input(UInt(WLEN.W))

      val takenPre = Output(Bool())
      // val takenPreValid = Output(Bool())
      val takenPrePC = Output(UInt(32.W))
      val ready = Output(Bool())
    })

    val rs1x0 = (io.rs1Addr === 0.U(5.W))
    val rs1x1 = (io.rs1Addr === 1.U(5.W))
    val rs1xn = !(rs1x0 | rs1x1)
    val op1 = Mux(io.bxx | io.jal, io.pc,
                Mux(io.jalr & rs1x0, 0.U(64.W),
                Mux(io.jalr & rs1x1, io.rs1x1Data, io.rs1Data)))
    val op2 = io.imm
    val takenMiss = io.takenMiss

    def defaultState() : UInt = 1.U (2.W)
    val bits2 = RegInit(defaultState())
    val prBits = bits2

// Update 2bits
    when(io.fire & io.takenValid ){   /*EX 反馈信息*/
      bits2 := LookupTreeDefault(prBits, defaultState(), List(
        0.U -> Mux(takenMiss, 0.U, 1.U),
        1.U -> Mux(takenMiss, 0.U, 2.U),
        2.U -> Mux(takenMiss, 1.U, 3.U),
        3.U -> Mux(takenMiss, 3.U, 2.U)
      ))
    }

    // io.takenPreValid := io.valid
    io.takenPre := Mux(io.jal | io.jalr, true.B,
                    Mux(io.bxx, prBits(1).asBool(), false.B))
    // io.takenPre := Mux((io.jal | io.jalr | io.bxx), prBits(1).asBool(), false.B)
    io.takenPrePC := Mux(io.takenPre, op1 + op2, 0.U)
    io.ready := RegNext(io.fire)  // 当前需要一周期完成
    // io.ready := RegNext(io.valid & io.fire)  // 当前需要一周期完成



    // io.takenPrePC := op1 + op2
    // io.takenPre := io.jal | io.jalr | (io.bxx & io.imm(63)) //jal、jalr、以及向后一定跳转
  }