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
      val takenMiss = Input(Bool())     // 预测失败信号
      val exTakenPre = Input(Bool())
      val takenPC = Input(UInt(WLEN.W))
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
    val BhtWidth = 8
    val BhtSize = 64
    val BhtAddrSize = log2Up(BhtSize)       // 6
    val PhtSize = 256                       // 2^8=256
    // val PhtSize = 2 ^ BhtWidth           // 2^8=256

    def defaultState() : UInt = 1.U (2.W)  //2bits start 
    def bhtAddr(x: UInt) : UInt = x(1 + BhtAddrSize, 2)   // (7, 2) //TODO: Add Hash
    def phtAddr(x: UInt, bhtData: UInt) : UInt = x(1 + BhtWidth, 2) ^ bhtData   // pc(9 ,2) ^ bht Data

    val bht = RegInit(VecInit(Seq.fill(BhtSize)(0.U(BhtWidth.W))))  // 64 * 8 bits
    val pht = RegInit(VecInit(Seq.fill(PhtSize)(defaultState())))   // 256 * 2 (01) bits
  
    val bhtAddrT = bhtAddr(io.pc)
    val bhtData = bht(bhtAddrT)
    val phtAddrT = phtAddr(io.pc, bhtData)
    val phtData = pht(phtAddrT)

    // val bhtData = bht(bhtAddr(io.pc))
    // val phtData = pht(phtAddr(io.pc, bhtData))

  // 基于全局分支预测方法
    //TODO：添加hash；扩大ghr位宽；
    // val ghr = RegInit(0.U(BhtWidth.W))
    // val phtAddrT = phtAddr(io.pc, ghr)
    // val phtData = pht(phtAddrT)
    // when(io.fire && io.takenValid) {
    //   // bht(bhtWAddr) := io.exTakenPre ## bhtWData(BhtWidth-1, 1)
    //   ghr := ghr(BhtWidth-2, 0) ## io.exTakenPre
    // }
    // val phtWAddr = phtAddr(io.takenPC, ghr)
    // val phtWData = pht(phtWAddr)

//*------------------------------ update: pht bht -----------------------------------
    val bhtWAddr = bhtAddr(io.takenPC)
    val bhtWData = bht(bhtWAddr) 
    when(io.fire && io.takenValid) {
      // bht(bhtWAddr) := io.exTakenPre ## bhtWData(BhtWidth-1, 1)
      bht(bhtWAddr) :=  bhtWData(BhtWidth-2, 0) ## io.exTakenPre
    }

    val phtWAddr = phtAddr(io.takenPC, bhtWData)
    val phtWData = pht(phtWAddr)

// update pht     
    when(io.fire & io.takenValid ){                                              /*EX 反馈信息, 更新相对应的PHT*/
      pht(phtWAddr) := LookupTreeDefault(phtWData, defaultState(), List(
        "b00".U -> Mux(takenMiss, "b01".U, "b00".U),     // Stronngly taken
        "b01".U -> Mux(takenMiss, "b10".U, "b00".U),     // Weakly taken
        "b10".U -> Mux(takenMiss, "b01".U, "b11".U),     // Weakly not taken
        "b11".U -> Mux(takenMiss, "b10".U, "b11".U)      // Strongly not takenaaa
      ))
    }

//*------------------------------ Res --------------------------------------------
    io.takenPre := Mux(io.valid,
                    Mux(io.jal | io.jalr, true.B,
                      Mux(io.bxx, phtData(1).asBool(), false.B)), false.B)                   // pht
    io.takenPrePC := Mux(io.valid && io.takenPre, op1 + op2, 0.U)
    io.ready := Mux(io.valid && io.bxx, RegNext(io.fire), io.fire)  // 只有bxx指令才需要延迟一个周期,从2bits reg读取数据
  }