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

    val BhtWidth = 8
    val BhtSize = 64
    val BhtAddrSize = log2Up(BhtSize)       // 6
    val PhtNum = 3                          // P0:CPHT P1:GHR P2:BHT
    val PhtSize = 256                       // 2^8=256
    // val PhtSize = 2 ^ BhtWidth           // 2^8=256
    val hashres = 216613626
    val prime   = 16777619

    def defaultState()                  : UInt = 1.U (2.W)                      // 2bits start 
    def bhtAddr(x: UInt)                : UInt = x(1 + BhtAddrSize, 2)          // PC(7, 2) -> bht //TODO: Add Hash 
    def phtAddr(x: UInt, bhtData: UInt) : UInt = x(1 + BhtWidth, 2) ^ bhtData   // pc(9 ,2) ^ bht Data
    def hash(pc: UInt, hashres:UInt, FNV_prime:UInt) :UInt = {
      val hashresOr = hashres ^ pc
      val hashresM  = hashresOr * FNV_prime
      hashresM
    }

    def hashres(pc: UInt, hashres:UInt, FNV_prime:UInt) :UInt = {
      val hashres1 = hash(pc( 7: 0), hashres , prime)
      val hashres2 = hash(pc(15: 8), hashres1, prime)
      val hashres3 = hash(pc(23:16), hashres2, prime)
      val hashres4 = hash(pc(31:24), hashres3, prime)
      hashres4(7:0)
    }

    val ghr = RegInit(0.U(BhtWidth.W))
    val bht = RegInit(VecInit(Seq.fill(BhtSize)(0.U(BhtWidth.W))))  // 64 * 8 bits
    val pht = RegInit(VecInit(Seq.fill(PhtNum)(VecInit(Seq.fill(PhtSize)(defaultState())))))   // 3 * 256 * 2 (01) bits

    val p1Addr   = phtAddr(io.pc, ghr)
    val bhtData  = bht(bhtAddr(io.pc))
    val pht0Data = pht(0)(p1Addr)
    val pht1Data = pht(1)(p1Addr)
    val pht2Data = pht(2)(phtAddr(io.pc, bhtData))
    val phtData  = Mux(pht0Data(1).asBool(), pht2Data, pht1Data)

    // Output
    io.takenPre := Mux(io.valid,
                    Mux(io.jal | io.jalr, true.B,
                      Mux(io.bxx, phtData(1).asBool(), false.B)), false.B)
    io.takenPrePC := Mux(io.valid && io.takenPre, op1 + op2, 0.U)
    io.ready := Mux(io.valid && io.bxx, RegNext(io.fire), io.fire)                 // 只有bxx指令才需要延迟一个周期,从2bits reg读取数据

    // update: bht ghr
    val bhtWAddr = bhtAddr(io.takenPC)
    val bhtWData = bht(bhtWAddr)

    // update pht
    val pht1WAddr = phtAddr(io.takenPC, ghr)
    val pht2WAddr = phtAddr(io.takenPC, bhtWData)   //NOTE:bhr
    val pht0WData = pht(0)(pht1WAddr)
    val pht1WData = pht(1)(pht1WAddr)
    val pht2WData = pht(2)(pht2WAddr)                   //NOTE:bhr

    val p1TakenAddr = phtAddr(io.takenPC, ghr)
    val p1TakenTure = pht(1)(p1TakenAddr)(1).asBool()
    val p1Suc = p1TakenTure === io.exTakenPre
    
    val p2TakenAddr = bht(bhtAddr(io.takenPC))
    val p2TakenTure = pht(2)(p2TakenAddr)(1).asBool()
    val p2Suc = p2TakenTure === io.exTakenPre

    val pht0Choice = p1Suc ## p2Suc

// update pht
    when(io.fire & io.takenValid ){                                              /*EX 反馈信息, 更新相对应的PHT*/
      pht(0)(pht1WAddr) := LookupTreeDefault(pht0WData, defaultState(), List(
        "b00".U -> Mux(pht0Choice === "b01".U, "b01".U, "b00".U),     // Stronngly taken
        "b01".U -> Mux(pht0Choice === "b01".U, "b10".U, 
                      Mux(pht0Choice === "b10".U, "b00".U, "b01".U)),     // Weakly taken
        "b10".U -> Mux(pht0Choice === "b10".U, "b01".U, 
                      Mux(pht0Choice === "b01".U, "b11".U, "b10".U)),     // Weakly not taken
        "b11".U -> Mux(pht0Choice === "b10".U, "b10".U, "b11".U)      // Strongly not takenaaa
      ))
    } 
    when(io.fire & io.takenValid ){                                              /*EX 反馈信息, 更新相对应的PHT*/
      pht(1)(pht1WAddr) := LookupTreeDefault(pht1WData, defaultState(), List(
        "b00".U -> Mux(takenMiss, "b01".U, "b00".U),     // Stronngly taken
        "b01".U -> Mux(takenMiss, "b10".U, "b00".U),     // Weakly taken
        "b10".U -> Mux(takenMiss, "b01".U, "b11".U),     // Weakly not taken
        "b11".U -> Mux(takenMiss, "b10".U, "b11".U)      // Strongly not takenaaa
      ))
    }
    when(io.fire & io.takenValid ){                                              /*EX 反馈信息, 更新相对应的PHT*/
      pht(2)(pht2WAddr) := LookupTreeDefault(pht2WData, defaultState(), List(
        "b00".U -> Mux(takenMiss, "b01".U, "b00".U),     // Stronngly taken
        "b01".U -> Mux(takenMiss, "b10".U, "b00".U),     // Weakly taken
        "b10".U -> Mux(takenMiss, "b01".U, "b11".U),     // Weakly not taken
        "b11".U -> Mux(takenMiss, "b10".U, "b11".U)      // Strongly not takenaaa
      ))
    }
    
    when(io.fire && io.takenValid) {
      bht(bhtWAddr) :=  bhtWData(BhtWidth-2, 0) ## io.exTakenPre
      ghr := ghr(BhtWidth-2, 0) ## io.exTakenPre
    }

  }