import chisel3._
import chisel3.util._
import Constant._
import utils._
import javax.swing.InputMap
import scala.collection.Stepper.UnboxingIntStepper
/**
  * biomodal predictor
  *   size is 2KB;
  *   choose is 13bits, pc[15 : 3];
  * ****************************************
  * First:实现简单静态分支预测-向后跳转
  */

  class bht extends Module {
    val io = IO(new Bundle {
      val valid = Input(Bool())
      val fire = Input(Bool())
      val pc = Input(UInt(32.W)) //Current PC

      val jal = Input(Bool())
      val jalr = Input(Bool())
      val bxx = Input(Bool())
      val imm = Input(UInt(XLEN.W))
      val rs1Addr = Input(UInt(5.W))

      val rs1Data = Input(UInt(64.W))   //ret jump address
      val rs1x1Data = Input(UInt(64.W))
      val exeX1En = Input(Bool())
      val exeAluRes = Input(UInt(64.W))
      val memX1En = Input(Bool())
      val memAluRes = Input(UInt(64.W))
      val wbRdEn = Input(Bool())
      val wbRdAddr = Input(UInt(5.W))
      val wbRdData = Input(UInt(64.W))

      val takenValid = Input(Bool())    // predecte result
      val takenMiss = Input(Bool())
//      val nextPC = Input(UInt(WLEN.W))

      val takenPre = Output(Bool())
      val takenPrePC = Output(UInt(32.W))
      val ready = Output(Bool())
    })

    val rs1x0 = (io.rs1Addr === 0.U(5.W))
    val rs1x1 = (io.rs1Addr === 1.U(5.W))
    val rs1xn = !(rs1x0 | rs1x1)
    val rs1x1Data = Mux(io.exeX1En, io.exeAluRes,          // EXE选择ALU计算后结果
                      Mux(io.memX1En, io.memAluRes,        // NEN选择输入结果
                        Mux(io.wbRdEn && io.wbRdAddr === 1.U, io.wbRdData,
                          io.rs1x1Data)))
    val op1 = Mux(io.bxx | io.jal, io.pc,
                Mux(io.jalr & rs1x0, 0.U(64.W),
                  Mux(io.jalr & rs1x1, rs1x1Data, io.rs1Data)))
    val op2 = io.imm
    val takenMiss = io.takenMiss

//*------------------------------ BHT PHT --------------------------------------------
    val BhtWidth = 9
    val BhtSize = 64
    val BhtAddrSize = log2Up(BhtSize)   // 7
    val PhSize = 2 ^ BhtWidth

    def defaultState() : UInt = 1.U (2.W)
    def bhtAddr(x: UInt) : UInt = x(1 + BhtSize, 2)
    def phtAddr(x: UInt, bhtData: UInt) : UInt = x(1 + BhtSize, 2) ^ bhtData

    val bht = RegInit(VecInit(Seq.fill(BhtSize)(0.U(BitWidth.W))))  // 64 * 9 bits
    val pht = RegFile(VecInit(Seq.fill(PhtSize)(defaultState())))   // 256 * 2 (01) bits

    val bhtData = bht(bhtAddr(io.pc))
    val phtData = pht(phtAddr(io.pc, bhtData))

//*------------------------------ update: pht bht -----------------------------------
    //todo()


//*------------------------------ 2 bits --------------------------------------------
    val bits2 = RegInit(defaultState())
    val prBits = bits2

// Update 2bits
    when(io.fire & io.takenValid ){   /*EX 反馈信息*/
      bits2 := LookupTreeDefault(prBits, defaultState(), List(    //todo()
        0.U -> Mux(takenMiss, 0.U, 1.U),     // Stronngly taken
        1.U -> Mux(takenMiss, 0.U, 2.U),     // Weakly taken
        2.U -> Mux(takenMiss, 1.U, 3.U),     // Weakly not taken
        3.U -> Mux(takenMiss, 3.U, 2.U)      // Strongly not taken
      ))
    }

//*------------------------------ Res --------------------------------------------
    io.takenPre := Mux(io.valid,
                    Mux(io.jal | io.jalr, true.B,
                      Mux(io.bxx, phtData(1).asBool(), false.B)), false.B)                   // pht
                      // Mux(io.bxx, prBits(1).asBool(), false.B)), false.B)                   // 2bits
    io.takenPrePC := Mux(io.valid && io.takenPre, op1 + op2, 0.U)
    io.ready := Mux(io.valid && io.bxx, RegNext(io.fire), io.fire)  // 只有bxx指令才需要延迟一个周期,从2bits reg读取数据

    //* --------- 静态分支预测：向后跳 ------------
    // io.takenPrePC := op1 + op2
    // io.takenPre := io.jal | io.jalr | (io.bxx & io.imm(63)) //jal、jalr、以及向后一定跳转
  }